--アルカナフォースEX－THE CHAOS RULER
-- 效果：
-- 卡名不同的「秘仪之力」怪兽×3
-- 把自己·对方场上的上记的卡送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：把1只10星「秘仪之力」怪兽无视召唤条件从手卡·卡组特殊召唤。
-- ●里：把持有进行投掷硬币效果的1张卡从卡组加入手卡。
-- ②：只要「光之结界」在场地区域存在，对方不能把场上的怪兽的效果发动。
local s,id,o=GetID()
-- 注册该卡的特殊召唤手续（融合素材+接触融合+苏生限制）以及①的特殊召唤诱发效果和②的封印效果。
function s.initial_effect(c)
	-- 记录这张卡效果文中提到了卡号73206827的「光之结界」，用于关联判定。
	aux.AddCodeList(c,73206827)
	-- 为这张卡登记融合召唤手续：需要用3只满足s.ffilter条件的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,s.ffilter,3,false)
	c:EnableReviveLimit()
	-- 为这张卡登记接触融合手续：将双方场上的满足s.cffilter条件的卡作为素材送去墓地（cost）来特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,s.cffilter,LOCATION_MZONE,LOCATION_MZONE,Duel.SendtoGrave,REASON_COST)
	-- 把自己·对方场上的上记的卡送去墓地的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。●表：把1只10星「秘仪之力」怪兽无视召唤条件从手卡·卡组特殊召唤。●里：把持有进行投掷硬币效果的1张卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e1:SetCategory(CATEGORY_COIN+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	-- ②：只要「光之结界」在场地区域存在，对方不能把场上的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.condition)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
end
s.toss_coin=true
-- 融合素材过滤：要求素材为「秘仪之力」系列怪兽，且与已选素材的融合代码不重复，从而保证素材卡名各不相同。
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x5) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 接触融合素材过滤：素材必须能作为代价送去墓地，且是自己场上的怪兽或对方场上的表侧表示怪兽，符合“把自己·对方场上的上记的卡送去墓地”的要求。
function s.cffilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end
-- ①效果的发动时点判定：满足发动条件（本卡特殊召唤成功），并设置操作信息为进行1次硬币投掷。
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的操作信息标记为投掷硬币分类，用于后续效果互动判定（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 表效果的选择条件：从手卡·卡组选1只10星「秘仪之力」怪兽，且该怪兽无视召唤条件可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 里效果的选择条件：从卡组选1张持有投掷硬币效果且能够加入手卡的卡。
function s.thfilter(c)
	-- 判断卡片是否拥有投掷硬币效果特性（EFFECT_FLAG_COIN）且当前可被加入手卡。
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- 处理①效果：若「光之结界」适用则直接选择表/里效果，否则投1次硬币。表：从手卡·卡组特殊召唤1只10星「秘仪之力」怪兽；里：从卡组将1张持有投掷硬币效果的卡加入手卡并向对方确认。
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 检测【光之结界】(73206827)的效果是否生效中。若在生效中，自己的「秘仪之力」怪兽的召唤·反转召唤·特殊召唤时发动的效果不进行投掷硬币而选里表的其中1个适用。
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 检查是否满足表选项：场上主要怪兽区有空位，且卡组·手卡存在符合条件的10星「秘仪之力」怪兽。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		-- 检查是否满足里选项：卡组存在持有投掷硬币效果且可加入手卡的卡。
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		if b1 and not b2 then
			-- 若只有表选项可用，则向对方提示本卡选择了表的效果（提示文字编号60）。
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 若只有里选项可用，则向对方提示本卡选择了里的效果（提示文字编号61）。
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 当表里两个选项都可用时，由玩家从选项中选择一个，返回值1代表表、0代表里。
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	-- 若「光之结界」未适用，则进行1次投掷硬币，正面(1)为表、反面(0)为里。
	else res=Duel.TossCoin(tp,1) end
	if res==1 then
		-- 特殊召唤前检查主要怪兽区是否有空位，若无空位则无法特殊召唤，直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 弹出“请选择要特殊召唤的卡”的选择提示框。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组选择1只满足s.spfilter条件的10星「秘仪之力」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽无视召唤条件，以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 弹出“请选择要加入手卡的卡”的选择提示框。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足s.thfilter条件的持有投掷硬币效果的卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入持有者的手卡（不指定player则给持有者），此操作视为效果处理。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的那张卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的条件：场上场地区域存在「光之结界」时，本效果适用。
function s.condition(e)
	-- 检查当前生效的场地卡是否为「光之结界」（73206827），不限定控制者，只看场地区域。
	return Duel.IsEnvironment(73206827,PLAYER_ALL,LOCATION_FZONE)
end
-- ②效果的限制判定：对方发动的效果若是在场上区域发动的怪兽效果，则不能发动；从其他区域（手卡·墓地等）发动的怪兽效果不受此限制。
function s.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc&LOCATION_ONFIELD~=0 and re:IsActiveType(TYPE_MONSTER)
end
