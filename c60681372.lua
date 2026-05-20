--妖魔ヌリカベ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这个回合没有送去墓地的这张卡在墓地存在的场合，支付1000基本分，以自己墓地1只其他的不死族怪兽为对象才能发动。那只怪兽和这张卡特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这个回合没有送去墓地的这张卡在墓地存在的场合，支付1000基本分，以自己墓地1只其他的不死族怪兽为对象才能发动。那只怪兽和这张卡特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	-- 设置发动条件：这张卡在这个回合没有送去墓地
	e1:SetCondition(aux.exccon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的Cost（支付基本分）判定与执行函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤自己墓地中可以特殊召唤的不死族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的Target（选择对象与合法性检查）函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) and chkc~=c end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在除自身以外、满足过滤条件的不死族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只其他的不死族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	g:AddCard(c)
	-- 设置特殊召唤的操作信息（包含对象怪兽和自身共2只）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理的Operation（特殊召唤及后续状态适用）函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的另一只不死族怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain()
		-- 检查这两张卡是否不受「王家长眠之谷」的影响
		and aux.NecroValleyFilter()(c) and aux.NecroValleyFilter()(tc)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 将这两张卡以表侧表示特殊召唤，并检查是否特殊召唤成功
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 遍历特殊召唤成功的怪兽组，对每只怪兽适用后续效果
			for sc in aux.Next(g) do
				-- 这个效果特殊召唤的怪兽的效果无效化
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1,true)
				-- 这个效果特殊召唤的怪兽的效果无效化
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2,true)
				-- 从场上离开的场合除外。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
				e3:SetValue(LOCATION_REMOVED)
				sc:RegisterEffect(e3,true)
			end
		end
	end
end
