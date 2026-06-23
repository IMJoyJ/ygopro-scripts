--ライゼオル・マスドライバー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这个回合中，以下效果适用。那之后，可以把这张卡作为自己场上的4阶超量怪兽的超量素材。
-- ●自己场上的「雷火沸动」怪兽的攻击力上升1000。
-- ②：这张卡从场上以外送去墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 初始化效果函数，创建并注册两个效果：①发动时效果和②送去墓地时效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上以外送去墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为满足条件的4阶超量怪兽（正面表示、等级4、超量怪兽且未被效果免疫）
function s.ovfilter(c,e)
	return c:IsFaceup() and c:IsRank(4) and c:IsType(TYPE_XYZ) and not c:IsImmuneToEffect(e)
end
-- 发动时效果处理函数，使自己场上的「雷火沸动」怪兽攻击力上升1000，并可选择是否将此卡作为超量素材
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这个回合中，以下效果适用。那之后，可以把这张卡作为自己场上的4阶超量怪兽的超量素材。●自己场上的「雷火沸动」怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力增加效果注册到全局环境，影响指定玩家的所有场上怪兽
	Duel.RegisterEffect(e1,tp)
	-- 检查此卡是否与当前效果相关联、场上是否存在满足条件的4阶超量怪兽、此卡能否叠放以及是否在场
	if c:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil,e)
		and c:IsCanOverlay() and c:IsOnField()
		-- 询问玩家是否将此卡作为超量素材使用
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否作为超量素材？"
		-- 中断当前效果处理，使后续操作视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要作为对象的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 从场上选择一个满足条件的4阶超量怪兽作为目标
		local tc=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
		if tc then
			c:CancelToGrave()
			-- 将此卡叠放至目标怪兽上
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end
-- 攻击力提升效果的目标过滤函数，筛选「雷火沸动」怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1be)
end
-- 除外效果发动条件判断函数，确保此卡不是从场上送去墓地的
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 除外效果的目标选择函数，选择对方墓地一张可除外的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查是否有满足条件的对方墓地卡片可供选择
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地一张可除外的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息，记录本次效果将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 除外效果执行函数，将选定的卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否与当前效果相关联且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 以效果原因将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
