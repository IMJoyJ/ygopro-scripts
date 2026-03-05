--波動竜騎士 ドラゴエクィテス
-- 效果：
-- 龙族同调怪兽＋战士族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。1回合1次，可以把墓地存在的1只龙族的同调怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用，得到相同效果。此外，只要这张卡在场上表侧攻击表示存在，对方的卡的效果发生的对自己的效果伤害由对方代受。
local s,id,o=GetID()
-- 初始化卡片效果函数
function c14017402.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要满足ffilter条件的龙族同调怪兽和战士族怪兽作为融合素材
	aux.AddFusionProcFun2(c,c14017402.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
	-- 1回合1次，可以把墓地存在的1只龙族的同调怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用，得到相同效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14017402,0))  --"获得龙族同调怪兽效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c14017402.target)
	e2:SetOperation(c14017402.operation)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧攻击表示存在，对方的卡的效果发生的对自己的效果伤害由对方代受
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_REFLECT_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(c14017402.refcon)
	c:RegisterEffect(e3)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(c14017402.splimit)
	c:RegisterEffect(e4)
end
c14017402.material_type=TYPE_SYNCHRO
-- 判断是否满足融合召唤条件
function c14017402.splimit(e,se,sp,st)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
	end
	return true
end
-- 判断是否触发反射伤害效果
function c14017402.refcon(e,re,val,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandler():GetControler() and e:GetHandler():IsAttackPos()
end
-- 过滤龙族同调怪兽的函数
function c14017402.ffilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 过滤可除外的龙族同调怪兽的函数
function c14017402.cpfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove()
end
-- 设置效果目标函数
function c14017402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c14017402.cpfilter(chkc) end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c14017402.cpfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c14017402.cpfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果处理函数
function c14017402.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡和自身是否有效且满足除外条件
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==1 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local code=tc:GetOriginalCode()
		local reset_flag=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		-- 将自身卡面代码更改为目标卡的原始卡号
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(reset_flag)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		local cid=c:CopyEffect(code,reset_flag,1)
		-- 在结束阶段时重置效果
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(1162)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabel(cid)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.rstop)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段时重置效果的处理函数
function s.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 显示对象卡被选中的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 提示对方玩家效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
