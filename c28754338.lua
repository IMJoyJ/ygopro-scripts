--真海皇 トライドン
-- 效果：
-- 把这张卡和自己场上1只海龙族怪兽解放才能发动。从手卡·卡组把1只「海皇龙 波塞德拉」特殊召唤。那之后，对方场上的全部怪兽的攻击力下降300。
function c28754338.initial_effect(c)
	-- 效果原文内容：把这张卡和自己场上1只海龙族怪兽解放才能发动。从手卡·卡组把1只「海皇龙 波塞德拉」特殊召唤。那之后，对方场上的全部怪兽的攻击力下降300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28754338,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28754338.spcost)
	e1:SetTarget(c28754338.sptg)
	e1:SetOperation(c28754338.spop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查是否满足解放条件并选择解放的卡
function c28754338.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则层面操作：判断是否可以解放此卡和场上一只海龙族怪兽
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_SEASERPENT) end
	-- 规则层面操作：提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 规则层面操作：选择场上一只海龙族怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_SEASERPENT)
	rg:AddCard(c)
	-- 规则层面操作：将选中的卡进行解放
	Duel.Release(rg,REASON_COST)
end
-- 规则层面操作：定义可特殊召唤的卡片过滤条件
function c28754338.filter(c,e,tp)
	return c:IsCode(47826112) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置特殊召唤效果的发动条件
function c28754338.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		-- 规则层面操作：判断手卡或卡组中是否存在「海皇龙 波塞德拉」
		and Duel.IsExistingMatchingCard(c28754338.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁操作信息，表示将要特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 规则层面操作：执行特殊召唤及后续效果处理
function c28754338.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从手卡或卡组中选择一张「海皇龙 波塞德拉」
	local g=Duel.SelectMatchingCard(tp,c28754338.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 规则层面操作：将选中的卡特殊召唤到场上
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 规则层面操作：中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 规则层面操作：获取对方场上所有正面表示的怪兽
		local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=tg:GetFirst()
		while tc do
			-- 效果原文内容：对方场上的全部怪兽的攻击力下降300。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=tg:GetNext()
		end
	end
end
