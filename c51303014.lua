--エレキック・ファイティング・ポーター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把最多2只3星以下的光属性怪兽特殊召唤。这个效果把原本种族相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽可以直接攻击。这个效果把原本等级相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽不会被战斗破坏。
local s,id,o=GetID()
-- 初始化函数：创建并注册“电气念力战斗传送士”的魔法卡发动效果，限定1回合1次，可从手牌特殊召唤光属性3星以下怪兽，并根据特殊召唤的怪兽原本种族/等级是否相同附加直接攻击或战斗破坏抗性。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡把最多2只3星以下的光属性怪兽特殊召唤。这个效果把原本种族相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽可以直接攻击。这个效果把原本等级相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：选择手牌中光属性、等级3以下且能被该效果正常特殊召唤的怪兽。
function s.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动条件：自己主要怪兽区域有空位，且手牌中存在至少1只符合条件的怪兽；同时登记效果将进行特殊召唤操作。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足光属性、3星以下且可被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，声明本效果会从手牌特殊召唤怪兽，数量预计为1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理流程：计算实际可特殊召唤数量（最多2只且受空位限制），若己方被青眼精灵龙的效果适用中则最多1只；玩家选择1~2只符合条件的怪兽，分别以表侧攻击表示特殊召唤；若选择的怪兽原本种族全部相同则赋予直接攻击，原本等级全部相同则赋予战斗破坏抗性；最后完成特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算可特殊召唤的上限，取2与场上可用怪兽区域空格数的较小值。
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 向玩家显示选择提示，要求其选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1~ct只满足条件且可被特殊召唤的怪兽作为对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,ct,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 遍历已选择的怪兽组，对每只怪兽执行后续的特殊召唤和效果赋予处理。
	for tc in aux.Next(g) do
		-- 将当前怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区域（分步特殊召唤步骤）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		if g:GetClassCount(Card.GetOriginalRace)==1 and g:GetCount()>1 then
			-- 这个效果把原本种族相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽可以直接攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		if g:GetClassCount(Card.GetOriginalLevel)==1 and g:GetCount()>1 then
			-- 这个效果把原本等级相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽不会被战斗破坏。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetValue(1)
			tc:RegisterEffect(e2)
		end
	end
	-- 完成所有分步特殊召唤，整体结算特殊召唤成功的时点与相关效果。
	Duel.SpecialSummonComplete()
end
