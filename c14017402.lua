--波動竜騎士 ドラゴエクィテス
-- 效果：
-- 龙族同调怪兽＋战士族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。1回合1次，可以把墓地存在的1只龙族的同调怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用，得到相同效果。此外，只要这张卡在场上表侧攻击表示存在，对方的卡的效果发生的对自己的效果伤害由对方代受。
local s,id,o=GetID()
-- 初始化波动龙骑士的效果：允许融合召唤的苏生限制、注册龙族同调怪兽+战士族怪兽的融合手续、注册除外并复制效果的起动效果、反射对方效果伤害的永续效果、以及融合召唤条件限制。
function c14017402.initial_effect(c)
	c:EnableReviveLimit()
	-- 为波动龙骑士添加融合召唤手续：以一只满足ffilter的龙族同调怪兽和一只战士族怪兽作为融合素材。
	aux.AddFusionProcFun2(c,c14017402.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
	-- 1回合1次，可以把墓地存在的1只龙族的同调怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用，得到相同效果。
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
	-- 此外，只要这张卡在场上表侧攻击表示存在，对方的卡的效果发生的对自己的效果伤害由对方代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_REFLECT_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(c14017402.refcon)
	c:RegisterEffect(e3)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(c14017402.splimit)
	c:RegisterEffect(e4)
end
c14017402.material_type=TYPE_SYNCHRO
-- 特殊召唤条件限制函数：当此卡在额外卡组时，只允许通过融合召唤方式特殊召唤；当不在此位置时不加限制。
function c14017402.splimit(e,se,sp,st)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
	end
	return true
end
-- 反射伤害的判定条件：伤害来自效果、伤害来源是对方的卡的效果、且此卡在场上攻击表示。
function c14017402.refcon(e,re,val,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandler():GetControler() and e:GetHandler():IsAttackPos()
end
-- 融合素材过滤：怪兽为龙族且拥有同调怪兽的融合素材类型（即龙族同调怪兽）。
function c14017402.ffilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 复制对象过滤：怪兽为龙族、是同调怪兽且能够被除外。
function c14017402.cpfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove()
end
-- 起动效果的目标定义：检查墓地是否存在可除外的龙族同调怪兽，若有则提示玩家选择1只，并设定为除外对象。
function c14017402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c14017402.cpfilter(chkc) end
	-- 在发动时检查是否存在至少1只满足条件的墓地龙族同调怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c14017402.cpfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 显示选择卡片提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从双方墓地选择1只龙族同调怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c14017402.cpfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁的操作信息：本次处理将除外1张墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果处理：对象仍关联且为龙族时将其除外；若成功除外1张且本卡仍关联、表侧表示，则获取对象卡的卡名，注册卡名变更效果并复制该怪兽的效果，同时注册在结束阶段重置的触发效果。
function c14017402.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡仍与效果关联、仍为龙族、成功除外1张，且本卡仍关联并表侧表示，才继续复制效果。
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==1 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local code=tc:GetOriginalCode()
		local reset_flag=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		-- 直到结束阶段时当作和那只怪兽同名卡使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(reset_flag)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		local cid=c:CopyEffect(code,reset_flag,1)
		-- 直到结束阶段时，在结束阶段重置所复制的效果和卡名变更。
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
-- 结束阶段重置处理：重置复制效果、取消卡名变更，并提示双方该卡恢复原状。
function s.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 显示本卡被选中的动画提示，表示卡名效果恢复。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示此卡恢复了原样（结束阶段重置完成）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
