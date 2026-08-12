--ピットナイト・フィル
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在连接怪兽所连接区特殊召唤的场合，以自己场上1只攻击力1500以下的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击，那只怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，下个回合的准备阶段才能发动。这张卡从墓地特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，启用复活限制，添加连接召唤手续，注册3个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2个满足效果怪兽类型的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2)
	-- 效果①：在连接怪兽所连接区特殊召唤成功时发动，使对象怪兽在同1次战斗阶段中可以作2次攻击
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"2次攻击"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- 效果②：被战斗·效果破坏送去墓地时发动，记录下个回合的准备阶段才能发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetOperation(s.spreg)
	c:RegisterEffect(e2)
	-- 效果②：下个回合的准备阶段发动，从墓地特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 判断是否在连接怪兽所连接区特殊召唤成功
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方连接怪兽组
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取对方连接怪兽组
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	lg1:Merge(lg2)
	return lg1 and lg1:IsContains(e:GetHandler())
end
-- 筛选表侧表示且攻击力1500以下的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500)
end
-- 选择对象怪兽，确认是否满足条件
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查是否满足发动条件，包括战斗阶段和存在符合条件的怪兽
	if chk==0 then return aux.bpcon() and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行效果①的操作，使对象怪兽获得额外攻击次数和战斗伤害翻倍效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使对象怪兽获得额外1次攻击次数
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		-- 使对象怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e2:SetCondition(s.damcon)
		-- 设置战斗伤害翻倍效果的值为2倍
		e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		tc:RegisterEffect(e2)
	end
end
-- 判断对象怪兽是否参与了战斗
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 记录被破坏时的触发信息，设置下个回合准备阶段发动的标记
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 设置下个回合准备阶段的标记为当前回合数+1
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 判断是否满足效果②的发动条件，即当前回合等于标记的回合数且拥有标记
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果②的发动条件，即当前回合等于标记的回合数且拥有标记
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
-- 设置效果②的发动条件，检查是否有足够的召唤区域和是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(id)
end
-- 执行效果②的操作，将卡从墓地特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
