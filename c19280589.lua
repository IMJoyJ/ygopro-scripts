--小天使テルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从怪兽区域送去墓地的场合才能发动。在自己场上把1只「忒勒斯的羽翼衍生物」（天使族·光·1星·攻/守0）特殊召唤。
-- ②：自己场上有「忒勒斯的羽翼衍生物」存在的场合，把墓地的这张卡和手卡1张魔法卡除外才能发动。在自己场上把2只「忒勒斯的羽翼衍生物」特殊召唤。这个效果的发动后，直到回合结束时自己不是从手卡中不能把怪兽特殊召唤。
function c19280589.initial_effect(c)
	-- ①：这张卡从怪兽区域送去墓地的场合才能发动。在自己场上把1只「忒勒斯的羽翼衍生物」（天使族·光·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19280589,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,19280589)
	e1:SetCondition(c19280589.tkcon1)
	e1:SetTarget(c19280589.tktg1)
	e1:SetOperation(c19280589.tkop1)
	c:RegisterEffect(e1)
	-- ②：自己场上有「忒勒斯的羽翼衍生物」存在的场合，把墓地的这张卡和手卡1张魔法卡除外才能发动。在自己场上把2只「忒勒斯的羽翼衍生物」特殊召唤。这个效果的发动后，直到回合结束时自己不是从手卡中不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19280589,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,19280590)
	e2:SetCost(c19280589.tkcost2)
	e2:SetCondition(c19280589.tkcon2)
	e2:SetTarget(c19280589.tktg2)
	e2:SetOperation(c19280589.tkop2)
	c:RegisterEffect(e2)
end
-- 判断此卡是否从怪兽区域被送去墓地
function c19280589.tkcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 准备发动效果①，检查是否满足特殊召唤token的条件
function c19280589.tktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的token
		and Duel.IsPlayerCanSpecialSummonMonster(tp,19280590,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：将要特殊召唤1只token
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行效果①的操作，如果满足条件则特殊召唤token
function c19280589.tkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤指定的token
	if Duel.IsPlayerCanSpecialSummonMonster(tp,19280590,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		-- 创建一个指定编号的token
		local token=Duel.CreateToken(tp,19280590)
		-- 将token特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断是否为魔法卡且可以作为除外的代价
function c19280589.tkcsfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 执行效果②的费用支付，选择手牌中的魔法卡和此卡除外
function c19280589.tkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家手牌中是否存在满足条件的魔法卡且此卡可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(c19280589.tkcsfilter,tp,LOCATION_HAND,0,1,c) and c:IsAbleToRemoveAsCost() end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择手牌中满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c19280589.tkcsfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：判断是否为「忒勒斯的羽翼衍生物」且正面表示
function c19280589.ctkfilter(c)
	return c:IsFaceup() and c:IsCode(19280590)
end
-- 判断自己场上是否存在「忒勒斯的羽翼衍生物」
function c19280589.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「忒勒斯的羽翼衍生物」
	return Duel.IsExistingMatchingCard(c19280589.ctkfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 准备发动效果②，检查是否满足特殊召唤2只token的条件
function c19280589.tktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤指定的token
		and Duel.IsPlayerCanSpecialSummonMonster(tp,19280590,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：将要特殊召唤2只token
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 执行效果②的操作，如果满足条件则特殊召唤2只token
function c19280589.tkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家是否可以特殊召唤指定的token
		and Duel.IsPlayerCanSpecialSummonMonster(tp,19280590,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		for i=1,2 do
			-- 创建一个指定编号的token
			local token=Duel.CreateToken(tp,19280590)
			-- 将token特殊召唤到场上
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- ②：自己场上有「忒勒斯的羽翼衍生物」存在的场合，把墓地的这张卡和手卡1张魔法卡除外才能发动。在自己场上把2只「忒勒斯的羽翼衍生物」特殊召唤。这个效果的发动后，直到回合结束时自己不是从手卡中不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19280589.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个永续效果，禁止玩家从手牌特殊召唤怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标函数：禁止从手牌特殊召唤怪兽
function c19280589.splimit(e,c)
	return not c:IsLocation(LOCATION_HAND)
end
