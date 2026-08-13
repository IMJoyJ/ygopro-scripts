--未界域のツチノコ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的槌子蛇」以外的场合，再从手卡把1只「未界域的槌子蛇」特殊召唤，自己从卡组抽1张。
-- ②：这张卡从手卡丢弃的场合才能发动。这张卡特殊召唤。
function c99745551.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的槌子蛇」以外的场合，再从手卡把1只「未界域的槌子蛇」特殊召唤，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99745551,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c99745551.spcost)
	e1:SetTarget(c99745551.sptg)
	e1:SetOperation(c99745551.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从手卡丢弃的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99745551,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,99745551)
	e2:SetTarget(c99745551.sptg2)
	e2:SetOperation(c99745551.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价判定：确认这张卡在手牌为非公开状态（未公开），即满足“把手卡的这张卡给对方观看”的发动条件。
function c99745551.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：用于筛选手牌中可被特殊召唤的「未界域的槌子蛇」（卡号99745551），要求该卡能够被当前效果特殊召唤。
function c99745551.spfilter(c,e,tp)
	return c:IsCode(99745551) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动目标：检查自己手牌是否存在至少1张可因效果丢弃的卡，并登记操作信息（本效果将丢弃自己手牌中的1张卡）。
function c99745551.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性的检查：确认自己手牌中存在至少1张能够因效果被丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 登记操作信息：声明本效果处理时会造成自己丢弃1张手牌（对象在效果处理时随机确定，故集合设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果①的处理：从自己全部手牌中由对方随机选1张并丢弃；若丢弃的不是槌子蛇且自己场上有怪兽区空位，则从手牌特殊召唤1只槌子蛇，并抽1张卡。
function c99745551.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己手牌的所有卡，作为对方随机选择的对象集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g<1 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 将随机选中的卡以“效果+丢弃”的理由送入墓地；若送入成功且该卡不是「未界域的槌子蛇」，才继续后续特殊召唤处理。
	if tc and Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(99745551)
		-- 确认自己主要怪兽区存在可用的空格，以满足从手牌特殊召唤槌子蛇的条件。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 检索自己手牌中所有满足特殊召唤条件的「未界域的槌子蛇」，准备进行特殊召唤。
		local spg=Duel.GetMatchingGroup(c99745551.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 当手牌中可特殊召唤的槌子蛇不止1张时，给出选择提示，要求自己选择要特殊召唤的那1张。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理，使后续的特殊召唤与抽卡视为不同时处理，避免错过时点（对应“场合”时点的正确发动）。
		Duel.BreakEffect()
		-- 将选定的槌子蛇以表侧攻击表示特殊召唤到自己的主要怪兽区，并以返回值判断是否召唤成功。
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 特殊召唤成功后，自己从卡组抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 效果②的发动目标：确认自己场上有怪兽区空位，且这张卡自身可以被特殊召唤，满足“从手卡丢弃的场合才能发动”的条件。
function c99745551.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认自己主要怪兽区存在空位，作为②效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：声明本效果将特殊召唤这张卡，对象确定为自身（c），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的处理：若这张卡仍与当前效果相关（未被除外、转移控制权等），则将其特殊召唤到场上。
function c99745551.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
