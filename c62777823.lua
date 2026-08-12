--CONTAIN！
-- 效果：
-- 这个卡名在规则上也当作「救援ACE队」卡使用。
-- ①：自己场上有「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。这个回合，那只效果怪兽不能攻击，效果无效化。自己场上有「救援ACE队 消防栓」存在的场合，再在这个回合让作为对象的怪兽不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 注册卡片的效果：自己场上有「救援ACE队」怪兽存在时，以对方场上1只效果怪兽为对象才能发动，使其不能攻击且效果无效，若自己场上有「救援ACE队 消防栓」存在则再使其不能作为特殊召唤素材
function s.initial_effect(c)
	-- ①：自己场上有「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。这个回合，那只效果怪兽不能攻击，效果无效化。自己场上有「救援ACE队 消防栓」存在的场合，再在这个回合让作为对象的怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「救援ACE队」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18b)
end
-- 发动条件：自己场上有「救援ACE队」怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「救援ACE队」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己场上表侧表示的「救援ACE队 消防栓」
function s.checkfilter(c)
	return c:IsCode(37617348) and c:IsFaceup()
end
-- 过滤条件：对方场上表侧表示的效果怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 效果①的发动准备：进行取对象检测，提示玩家选择目标，并将选择的怪兽设为效果对象，设置无效操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示效果怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息：请选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧表示的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将选中的1张卡的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果①的运行处理：使作为对象的怪兽不能攻击且效果无效，若自己场上有「救援ACE队 消防栓」存在，则再使其不能作为融合·同调·超量·连接召唤的素材
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查自己场上是否存在表侧表示的「救援ACE队 消防栓」
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT) then
		-- 这个回合，那只效果怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使与该怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e4=e2:Clone()
			e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e4)
		end
		-- 立即刷新场上卡片的无效状态
		Duel.AdjustInstantly()
		if check and not tc:IsImmuneToEffect(e) then
			-- 不能作为同调召唤的素材
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e5:SetRange(LOCATION_MZONE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e5:SetValue(1)
			tc:RegisterEffect(e5)
			local e6=e5:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e6:SetValue(s.fuslimit)
			tc:RegisterEffect(e6)
			local e7=e5:Clone()
			e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e7)
			local e8=e5:Clone()
			e8:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			tc:RegisterEffect(e8)
		end
	end
end
-- 限制该怪兽不能作为融合召唤的素材（仅在进行融合召唤时适用）
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
