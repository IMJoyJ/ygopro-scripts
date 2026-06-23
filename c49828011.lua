--Officiating Reverie
-- 效果：
-- 这张卡在手卡存在的场合：可以把1张其他手卡丢弃；这张卡特殊召唤。
-- 这张卡在自己墓地存在的状态，超量怪兽被送去墓地的场合（伤害步骤除外）：可以把这张卡除外；从自己墓地把1只不死族怪兽特殊召唤。
-- 这张卡被除外的下个回合的准备阶段：可以以自己场上1只不死族超量怪兽为对象；除外状态的这张卡在那只怪兽下面重叠作为超量素材。
-- 「尸会的空想」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果，注册3个效果：手卡特殊召唤效果（效果①）、墓地被动特召不死族效果（效果②）、被除外下个回合准备阶段作为超量素材效果（效果③）。
function s.initial_effect(c)
	-- 这张卡在手卡存在的场合：可以把1张其他手卡丢弃；这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡在自己墓地存在的状态，超量怪兽被送去墓地的场合（伤害步骤除外）：可以把这张卡除外；从自己墓地把1只不死族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	-- 检查自身是否能够作为cost除外，并将其除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 这张卡被除外的下个回合的准备阶段：可以以自己场上1只不死族超量怪兽为对象；除外状态的这张卡在那只怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"作为超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.mtcon)
	e3:SetTarget(s.mttg)
	e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
end
-- 过滤函数：用于判断手牌中是否存在可丢弃的其他卡片。
function s.dcfilter(c)
	return c:IsDiscardable()
end
-- 手卡特召效果（效果①）的cost检测与处理函数：从手卡丢弃1张除自身以外的卡片。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在除自身以外可丢弃的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张除自身以外的手卡。
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 手卡特召效果（效果①）的靶向检测函数：检查己方主要怪兽区域是否有空位，且自身可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息，预计将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手卡特召效果（效果①）的实际处理函数：若自身仍存在，则将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身在场上特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：用于判断送去墓地的卡是否为超量怪兽。
function s.cfilter(c,tp)
	return c:IsType(TYPE_XYZ)
end
-- 墓地效果（效果②）的发动条件判断函数：判断是否有超量怪兽送去墓地，且送去墓地的卡中不包含自身。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数：用于判断墓地里的卡是否为可特殊召唤的不死族怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地效果（效果②）的靶向检测函数：检查自己墓地是否存在其他可特殊召唤的不死族怪兽，且己方场上有空余的怪兽区域。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己墓地（除自身外）是否存在满足特殊召唤条件的不死族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
		-- 检查己方主要怪兽区域是否有可用的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置特殊召唤效果的操作信息，预计从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 墓地效果（效果②）的实际处理函数：若己方场上有空位，让玩家选择墓地中1只不死族怪兽特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区域没有可用的空位，则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在墓地选择1只满足条件且不受墓地针对效果影响的不死族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 素材效果（效果③）的条件判断函数：判断这张卡被除外的回合与当前回合数之差是否为1（即下个回合）。
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前回合是否是这张卡被除外的下个回合。
	return Duel.GetTurnCount()-c:GetTurnID()==1
end
-- 过滤函数：用于判断场上的怪兽是否为表侧表示的不死族超量怪兽。
function s.matfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
-- 素材效果（效果③）的靶向检测函数：检查自己场上是否存在可作为超量素材载体的不死族超量怪兽，且自身能够被叠放为素材。
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc) end
	-- 检查自己场上是否存在可成为效果对象的不死族超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果指向的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上的1只不死族超量怪兽作为效果的对象。
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 素材效果（效果③）的实际处理函数：将除外状态的自身重叠作为所选择超量怪兽的超量素材。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被选择作为超量素材载体的超量怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 将自身作为超量素材重叠在被选择的不死族超量怪兽下面。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
