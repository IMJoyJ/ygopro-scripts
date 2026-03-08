--死霊操りしパペットマスター
-- 效果：
-- ①：这张卡上级召唤成功时，支付2000基本分，以自己墓地2只恶魔族怪兽为对象才能发动。那些恶魔族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c41442341.initial_effect(c)
	-- 诱发选发效果，上级召唤成功时才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41442341,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c41442341.spcon)
	e1:SetCost(c41442341.spcost)
	e1:SetTarget(c41442341.sptg)
	e1:SetOperation(c41442341.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：这张卡是上级召唤成功
function c41442341.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 支付2000基本分
function c41442341.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 筛选满足条件的恶魔族怪兽
function c41442341.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择特殊召唤的对象，需满足是自己墓地的恶魔族怪兽且能特殊召唤
function c41442341.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c41442341.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地是否有2只满足条件的恶魔族怪兽
		and Duel.IsExistingTarget(c41442341.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择2只满足条件的恶魔族怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c41442341.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置连锁的操作信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 处理特殊召唤效果
function c41442341.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local fg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if fg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	if fg:GetCount()>1 and ft==1 then fg=fg:Select(tp,1,1,nil) end
	local tc=fg:GetFirst()
	while tc do
		-- 特殊召唤一张怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 特殊召唤的怪兽在本回合不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=fg:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
