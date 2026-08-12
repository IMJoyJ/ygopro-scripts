--銀河眼の残光竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「银河眼」怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从手卡·卡组选1只「银河眼光子龙」特殊召唤或在自己的超量怪兽下面重叠作为超量素材。这个效果在战斗阶段发动的场合，再让自己场上的全部「No.」超量怪兽的攻击力变成2倍。
function c62968263.initial_effect(c)
	-- ①：自己场上有「银河眼」怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62968263,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,62968263)
	e1:SetCondition(c62968263.spcon1)
	e1:SetTarget(c62968263.sptg1)
	e1:SetOperation(c62968263.spop1)
	c:RegisterEffect(e1)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从手卡·卡组选1只「银河眼光子龙」特殊召唤或在自己的超量怪兽下面重叠作为超量素材。这个效果在战斗阶段发动的场合，再让自己场上的全部「No.」超量怪兽的攻击力变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62968263,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:SetCountLimit(1,62968264)
	e2:SetCondition(c62968263.spcon2)
	e2:SetTarget(c62968263.sptg2)
	e2:SetOperation(c62968263.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「银河眼」怪兽
function c62968263.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b)
end
-- 效果①的发动条件：自己场上存在「银河眼」怪兽
function c62968263.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「银河眼」怪兽
	return Duel.IsExistingMatchingCard(c62968263.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的靶向与可行性检查：检查怪兽区域是否有空位，且自身是否可以特殊召唤
function c62968263.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤
function c62968263.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件：作为超量素材的这张卡为了发动超量怪兽的效果而被取除
function c62968263.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 过滤条件：手卡或卡组中的「银河眼光子龙」，且满足特殊召唤或作为超量素材重叠的条件
function c62968263.spfilter(c,e,tp)
	return c:IsCode(93717133)
		-- 检查是否有怪兽区域空格且该卡可以特殊召唤
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 或者自己场上存在超量怪兽且该卡可以作为超量素材重叠
		or (Duel.IsExistingMatchingCard(c62968263.matfilter,tp,LOCATION_MZONE,0,1,nil) and c:IsCanOverlay()))
end
-- 过滤条件：自己场上表侧表示的超量怪兽
function c62968263.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果②的靶向与可行性检查：检查手卡·卡组是否存在「银河眼光子龙」，并记录是否在战斗阶段发动
function c62968263.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在满足条件的「银河眼光子龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c62968263.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	local bpchk=0
	-- 检查当前是否处于战斗阶段
	if Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<PHASE_BATTLE then bpchk=1 end
	e:SetLabel(bpchk)
	-- 设置从手卡或卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤条件：自己场上表侧表示的「No.」超量怪兽
function c62968263.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end
-- 效果②的效果处理：特殊召唤「银河眼光子龙」或将其作为超量素材，若在战斗阶段发动则让场上全部「No.」超量怪兽攻击力翻倍
function c62968263.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「银河眼光子龙」
	local g=Duel.SelectMatchingCard(tp,c62968263.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local res=0
	if tc then
		-- 检查自己场上是否存在超量怪兽，且选中的卡可以作为超量素材重叠
		if Duel.IsExistingMatchingCard(c62968263.matfilter,tp,LOCATION_MZONE,0,1,nil) and tc:IsCanOverlay()
			-- 检查该卡是否无法特殊召唤，或者自己场上没有可用的怪兽区域空格
			and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
				-- 或者由玩家手动选择“作为超量素材”选项
				or Duel.SelectOption(tp,1152,aux.Stringid(62968263,2))==1) then  --"作为超量素材"
			-- 提示玩家选择表侧表示的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 让玩家选择自己场上1只表侧表示的超量怪兽
			local sg=Duel.SelectMatchingCard(tp,c62968263.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 将选中的「银河眼光子龙」重叠在所选超量怪兽下面作为超量素材
			Duel.Overlay(sg:GetFirst(),Group.FromCards(tc))
			res=1
		else
			-- 将选中的「银河眼光子龙」表侧表示特殊召唤到自己场上
			res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
		if res~=0 and e:GetLabel()==1 then
			-- 获取自己场上所有表侧表示的「No.」超量怪兽
			local tg=Duel.GetMatchingGroup(c62968263.atkfilter,tp,LOCATION_MZONE,0,nil)
			local tc=tg:GetFirst()
			while tc do
				-- 再让自己场上的全部「No.」超量怪兽的攻击力变成2倍。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetValue(tc:GetAttack()*2)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				tc=tg:GetNext()
			end
		end
	end
end
