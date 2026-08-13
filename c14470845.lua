--おジャマデュオ
-- 效果：
-- ①：在对方场上把2只「扰乱衍生物」（兽族·光·2星·攻0/守1000）守备表示特殊召唤。这衍生物不能为上级召唤而解放。「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把2只卡名不同的「扰乱」怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c14470845.initial_effect(c)
	-- ①：在对方场上把2只「扰乱衍生物」（兽族·光·2星·攻0/守1000）守备表示特殊召唤。这衍生物不能为上级召唤而解放。「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14470845.target)
	e1:SetOperation(c14470845.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把2只卡名不同的「扰乱」怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14470845,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	-- 设置②效果的发动条件：不在本卡被送去墓地的那个回合发动（若因返回手牌等特殊离场原因则除外），以此实现“这个效果在这张卡送去墓地的回合不能发动”的限制。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：从墓地除外这张卡（“把墓地的这张卡除外才能发动”）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c14470845.sptg)
	e2:SetOperation(c14470845.spop)
	c:RegisterEffect(e2)
end
-- ①效果发动时的合法条件检测：不受青眼精灵龙影响、对方怪兽区域至少有2个空位、且我方能够将「扰乱衍生物」守备表示特殊召唤到对方场上。
function c14470845.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查对方主要怪兽区域的可用空格是否大于1（至少2个空位），确保能够特殊召唤2只衍生物。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>1
		-- 检查我方是否能把「扰乱衍生物」（兽族·光·2星·攻0/守1000）以表侧守备表示特殊召唤到对方场上，此处指定了衍生物的全部参数。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN_MONSTER,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置操作信息：本次效果将生成2只衍生物（CATEGORY_TOKEN），用于连锁检测和时点触发。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果包含特殊召唤2只怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果处理：再次确认条件后，在对方场上特殊召唤2只「扰乱衍生物」，并分别赋予其“不能为上级召唤而解放”和“被破坏时控制者受到300伤害”的效果。
function c14470845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时再次检查对方怪兽区域空格是否不足2个，若不足则效果不处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<2 then return end
	-- 处理时再次确认能够特殊召唤「扰乱衍生物」到对方场上，否则效果不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN_MONSTER,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) then return end
	for i=1,2 do
		-- 创建第i只「扰乱衍生物」（卡号14470845+i）的衍生物卡片。
		local token=Duel.CreateToken(tp,14470845+i)
		-- 将衍生物以表侧守备表示特殊召唤到对方场上（不检查召唤条件与苏生限制），成功后才继续赋予衍生物相关效果。
		if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
			-- 这衍生物不能为上级召唤而解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			token:RegisterEffect(e1,true)
			-- 「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_LEAVE_FIELD)
			e2:SetOperation(c14470845.damop)
			token:RegisterEffect(e2,true)
		end
	end
	-- 完成本次连锁的特殊召唤处理（Duel.SpecialSummonComplete），触发特殊召唤成功时点时点。
	Duel.SpecialSummonComplete()
end
-- 衍生物离场时的效果：若该衍生物是被破坏离场，则向其离场前的控制者造成300点效果伤害，随后重置该效果。
function c14470845.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 以效果伤害形式，向被破坏衍生物离场前的控制者造成300点伤害。
		Duel.Damage(c:GetPreviousControler(),300,REASON_EFFECT)
	end
	e:Reset()
end
-- 效果②的过滤器：判断卡组中的卡是否是「扰乱」（0xf）字段怪兽，且能否被当前效果特殊召唤。
function c14470845.spfilter(c,e,tp)
	return c:IsSetCard(0xf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时判定：我方怪兽区至少2个空位，卡组存在至少2只卡名不同的「扰乱」怪兽，且未受到青眼精灵龙等多重特招限制。
function c14470845.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取我方卡组中所有满足「扰乱」字段且可被特殊召唤的怪兽集合。
		local g=Duel.GetMatchingGroup(c14470845.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 确认怪兽区空位超过1个，且卡组中满足条件的「扰乱」怪兽卡名种类不少于2。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and g:GetClassCount(Card.GetCode)>=2 end
	-- 设置操作信息：效果处理中将从卡组特殊召唤2只怪兽，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：若场上空位足够且卡组仍有2种以上不同卡名的「扰乱」怪兽，则选择其中2只卡名不同的怪兽特殊召唤到我方场上。
function c14470845.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方主要怪兽区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 再次取得卡组中符合条件的「扰乱」怪兽集合，供处理时选择。
	local g=Duel.GetMatchingGroup(c14470845.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 and g:GetClassCount(Card.GetCode)>1 then
		-- 向玩家显示选择提示：“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从符合条件的「扰乱」怪兽中选择2只卡名不同的怪兽（aux.dncheck保证卡名互不相同）。
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选择的2只「扰乱」怪兽以表侧表示特殊召唤到我方场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
