--大騎甲虫インヴィンシブル・アトラス
-- 效果：
-- 昆虫族怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：连接召唤的这张卡在攻击力是3000以下的场合不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
-- ③：可以把自己场上1只昆虫族怪兽解放，从以下效果选择1个发动。
-- ●从卡组把1只「骑甲虫」怪兽特殊召唤。
-- ●这张卡的攻击力直到回合结束时上升2000。
function c38229962.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要以2只以上满足条件的昆虫族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT),2)
	-- ①：连接召唤的这张卡在攻击力是3000以下的场合不会成为对方的效果的对象，不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(c38229962.condition)
	-- 设置该效果的判定函数：当这张卡成为对方发动的效果对象时，若效果发动者不是这张卡的控制者，则不能将其作为对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置该效果的判定函数：以对方发动且以这张卡为对象的效果造成的破坏，使其不会被对方的效果破坏。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c38229962.splimit)
	c:RegisterEffect(e3)
	-- ③：可以把自己场上1只昆虫族怪兽解放，从以下效果选择1个发动。●从卡组把1只「骑甲虫」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38229962,0))  --"从卡组特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,38229962)
	e4:SetCost(c38229962.spcost)
	e4:SetTarget(c38229962.sptg)
	e4:SetOperation(c38229962.spop)
	c:RegisterEffect(e4)
	-- ③：可以把自己场上1只昆虫族怪兽解放，从以下效果选择1个发动。●这张卡的攻击力直到回合结束时上升2000。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(38229962,1))  --"这张卡攻击力上升"
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,38229962)
	e5:SetCost(c38229962.atkcost)
	e5:SetTarget(c38229962.atktg)
	e5:SetOperation(c38229962.atkop)
	c:RegisterEffect(e5)
end
-- 判定条件：这张卡是连接召唤且攻击力在3000以下时，①效果才适用。
function c38229962.condition(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsAttackBelow(3000)
end
-- 限制特殊召唤的怪兽种族：不是昆虫族的怪兽不能进行特殊召唤。
function c38229962.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT)
end
-- 筛选可作为解放代价的昆虫族怪兽：必须是昆虫族，且控制者是发动玩家或表侧表示。
function c38229962.costfilter(c,tp)
	return c:IsRace(RACE_INSECT) and (c:IsControler(tp) or c:IsFaceup())
end
-- 解放代价筛选：在满足costfilter的基础上，解放这张卡后自己场上仍有空余的怪兽区。
function c38229962.spcostfilter(c,tp)
	-- 判断该怪兽可作为解放对象，并且解放后自己的怪兽区域仍有空格可用。
	return c38229962.costfilter(c,tp) and Duel.GetMZoneCount(tp,c)>0
end
-- 处理③效果的解放代价：发动前确认存在可解放且解放后仍有空位的昆虫族怪兽，选择1只解放作为代价。
function c38229962.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认是否存在至少1只满足解放条件且解放后仍有怪兽区空位的昆虫族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38229962.spcostfilter,1,nil,tp) end
	-- 选择自己场上1只满足条件的昆虫族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c38229962.spcostfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，该解放作为效果发动COST。
	Duel.Release(g,REASON_COST)
end
-- 从卡组检索满足条件的目标：持有「骑甲虫」字段且可以被特殊召唤的怪兽。
function c38229962.spfilter(c,e,tp)
	return c:IsSetCard(0x170) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标判断：确认卡组存在可特殊召唤的「骑甲虫」怪兽，向对方提示所选效果，并设置特殊召唤的操作信息。
function c38229962.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中存在至少1只可特殊召唤的「骑甲虫」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c38229962.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示此效果选择了哪个发动选项（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次连锁的处理信息：效果处理时将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：当自己的怪兽区有空位时，从卡组选择1只「骑甲虫」怪兽特殊召唤。
function c38229962.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的怪兽区是否还有空位可用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家从卡组选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中筛选并选择1只符合条件的「骑甲虫」怪兽。
		local g=Duel.SelectMatchingCard(tp,c38229962.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 处理攻击力上升选项的解放代价：选择并解放1只昆虫族怪兽（不能解放这张卡自身）。
function c38229962.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认场上是否存在除这张卡以外的可解放的昆虫族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38229962.costfilter,1,e:GetHandler(),tp) end
	-- 选择自己场上1只昆虫族怪兽作为解放代价，且不能选择这张卡自身。
	local g=Duel.SelectReleaseGroup(tp,c38229962.costfilter,1,1,e:GetHandler(),tp)
	-- 将选择的怪兽解放，作为效果发动COST。
	Duel.Release(g,REASON_COST)
end
-- 攻击力上升效果的发动判断：无条件允许发动，并向对方提示所选效果。
function c38229962.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示此效果发动选择了“攻击力上升”选项。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：这张卡仍表侧表示且与该效果关联时，攻击力上升2000直到回合结束。
function c38229962.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- ●这张卡的攻击力直到回合结束时上升2000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
