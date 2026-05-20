--ソウル・チャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。
-- ①：以自己墓地的怪兽任意数量为对象才能发动。那些怪兽特殊召唤，自己失去这个效果特殊召唤的怪兽数量×1000基本分。
function c54447022.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。①：以自己墓地的怪兽任意数量为对象才能发动。那些怪兽特殊召唤，自己失去这个效果特殊召唤的怪兽数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,54447022+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c54447022.spcost)
	e1:SetTarget(c54447022.sptg)
	e1:SetOperation(c54447022.spop)
	c:RegisterEffect(e1)
end
-- 定义发动的Cost函数，检查发动条件并注册本回合不能进行战斗阶段的效果
function c54447022.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段进行检测，若处于主要阶段2则无法发动（因为无法满足发动的回合不能进行战斗阶段的誓约）
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：以自己墓地的怪兽任意数量为对象才能发动。那些怪兽特殊召唤，自己失去这个效果特殊召唤的怪兽数量×1000基本分。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该限制效果，使发动玩家本回合不能进行战斗阶段
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：用于筛选自己墓地中可以特殊召唤的怪兽
function c54447022.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动的Target函数，进行对象选择与合法性检测
function c54447022.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 在发动时，检测自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检测自己墓地是否存在至少1只可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c54447022.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地中任意数量（不超过可用怪兽区域数）的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c54447022.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置特殊召唤的操作信息，用于后续连锁处理和卡片效果检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 定义效果处理的Operation函数，执行特殊召唤并扣除对应基本分
function c54447022.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取发动时选择的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡（当对象数量大于可用怪兽区域时）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将合法的对象怪兽以表侧表示特殊召唤，并记录成功特殊召唤的怪兽数量
	local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	-- 自己失去这个效果特殊召唤的怪兽数量×1000基本分
	Duel.SetLP(tp,Duel.GetLP(tp)-ct*1000)
end
