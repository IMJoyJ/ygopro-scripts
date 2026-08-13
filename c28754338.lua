--真海皇 トライドン
-- 效果：
-- 把这张卡和自己场上1只海龙族怪兽解放才能发动。从手卡·卡组把1只「海皇龙 波塞德拉」特殊召唤。那之后，对方场上的全部怪兽的攻击力下降300。
function c28754338.initial_effect(c)
	-- 把这张卡和自己场上1只海龙族怪兽解放才能发动。从手卡·卡组把1只「海皇龙 波塞德拉」特殊召唤。那之后，对方场上的全部怪兽的攻击力下降300。
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
-- 定义解放代价：选择自己场上1只海龙族怪兽，连同自身一起解放作为发动成本。
function c28754338.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检测：自身可解放，且自己场上有1只可解放的海龙族怪兽。
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_SEASERPENT) end
	-- 显示“请选择要解放的卡”的提示文字，用于选择解放怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只除自身以外的海龙族怪兽作为解放对象。
	local rg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_SEASERPENT)
	rg:AddCard(c)
	-- 将选择的海龙族怪兽和自身作为发动代价解放。
	Duel.Release(rg,REASON_COST)
end
-- 过滤器：检索卡名「海皇龙 波塞德拉」（47826112）且可以被特殊召唤的卡。
function c28754338.filter(c,e,tp)
	return c:IsCode(47826112) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标检测：解放后主要怪兽区仍有空位，且手卡/卡组存在满足条件的「海皇龙 波塞德拉」。
function c28754338.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定主要怪兽区空格数是否大于-2（即解放2只怪兽后仍至少有1个可用格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		-- 确认手卡或卡组中存在1只可特殊召唤的「海皇龙 波塞德拉」。
		and Duel.IsExistingMatchingCard(c28754338.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次操作包含特殊召唤，来源为手卡·卡组，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：若主要怪兽区有空位，选1只「海皇龙 波塞德拉」特殊召唤；成功后使对方场上全部怪兽攻击力下降300。
function c28754338.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若主要怪兽区没有可用空格，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只符合条件的「海皇龙 波塞德拉」。
	local g=Duel.SelectMatchingCard(tp,c28754338.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽表侧表示特殊召唤，成功则继续。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理，使后续攻击力下降效果视为另一次处理，避免时点被占用。
		Duel.BreakEffect()
		-- 取得对方场上全部表侧表示怪兽。
		local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=tg:GetFirst()
		while tc do
			-- 那之后，对方场上的全部怪兽的攻击力下降300。
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
