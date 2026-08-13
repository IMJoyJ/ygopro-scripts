--時械巫女
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：「时械神」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ③：把这张卡解放才能发动。从卡组把1只攻击力0的「时械神」怪兽加入手卡。
-- ④：把墓地的这张卡除外才能发动。从卡组把1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤。这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
function c27107590.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c27107590.sprcon)
	c:RegisterEffect(e1)
	-- ②：「时械神」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c27107590.dtcon)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放才能发动。从卡组把1只攻击力0的「时械神」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27107590,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c27107590.thcost)
	e3:SetTarget(c27107590.thtg)
	e3:SetOperation(c27107590.thop)
	c:RegisterEffect(e3)
	-- ④：把墓地的这张卡除外才能发动。从卡组把1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤。这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27107590,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c27107590.spcost)
	e4:SetTarget(c27107590.sptg)
	e4:SetOperation(c27107590.spop)
	c:RegisterEffect(e4)
end
-- ①的召唤规则条件：自己场上没有怪兽且主要怪兽区域有空位时，这张卡可从手卡特殊召唤。
function c27107590.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上主要怪兽区怪兽数量为0（满足①的发动条件之一）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查自己主要怪兽区有空余格子，确保特殊召唤有位置可用。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- ②的判定：被解放的怪兽必须是「时械神」字段的怪兽，此时这张卡可作为2只的数量。
function c27107590.dtcon(e,c)
	return c:IsSetCard(0x4a)
end
-- ③的代价：把这张卡解放作为发动代价，并检查其可解放。
function c27107590.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 实际解放这张卡，作为效果发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检索过滤：从卡组选出满足「时械神」字段、怪兽类型、攻击力0且能加入手卡的卡。
function c27107590.thfilter(c)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAttack(0) and c:IsAbleToHand()
end
-- ③的发动条件与目标设定：确认卡组存在符合条件的「时械神」怪兽，并设置把1张加入手卡的操作信息。
function c27107590.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1张以上符合检索条件的「时械神」怪兽，决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27107590.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时从卡组把1张卡加入手卡的信息（用于满足相关卡片的效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③的解决处理：从卡组选择1张符合条件的「时械神」怪兽加入手卡，并向对方确认。
function c27107590.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家从卡组选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张符合检索条件的「时械神」怪兽。
	local g=Duel.SelectMatchingCard(tp,c27107590.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ④的代价：自己本回合未特殊召唤过，且这张卡在墓地可除外；除外自身后，给自己附加本回合不能特殊召唤的自肃效果。
function c27107590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查本回合自己尚未进行过特殊召唤，且墓地中的这张卡可以作为代价除外。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and c:IsAbleToRemoveAsCost() end
	-- 将墓地中的这张卡表侧除外，作为发动代价。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- ④：把墓地的这张卡除外才能发动。从卡组把1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤。这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c27107590.splimit)
	e1:SetLabelObject(e)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，使本回合自己不能进行特殊召唤。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：若即将进行的特殊召唤不是由本效果（④）发动，则禁止特殊召唤。
function c27107590.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se~=e:GetLabelObject()
end
-- 特殊召唤的过滤条件：选择卡组中满足「时械神」字段、怪兽类型、攻击力0，并且可以被无视召唤条件特殊召唤的怪兽。
function c27107590.spfilter(c,e,tp)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAttack(0) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ④的发动条件：自己主要怪兽区有空位，且卡组存在符合特殊召唤条件的「时械神」怪兽。
function c27107590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「时械神」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c27107590.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时从卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ④的解决处理：从卡组选择1只符合条件的「时械神」怪兽无视召唤条件特殊召唤。
function c27107590.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己主要怪兽区仍有空位，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选择1只符合条件的「时械神」怪兽。
	local g=Duel.SelectMatchingCard(tp,c27107590.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「时械神」怪兽无视召唤条件以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
