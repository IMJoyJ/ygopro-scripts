--祭司 レヴァリー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡丢弃1张其他卡才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在的状态，超量怪兽被送去墓地的场合，把这张卡除外才能发动。从自己墓地把1只不死族怪兽特殊召唤。
-- ③：这张卡被除外的下个回合的准备阶段，以自己场上1只不死族超量怪兽为对象才能发动。把除外状态的这张卡作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 注册三个效果：①手卡的起动特殊召唤效果、②墓地在超量怪兽送去墓地时诱发的墓地特召效果、③除外状态在准备阶段诱发取对象的成为超量素材效果，各1回合1次
function s.initial_effect(c)
	-- ①：从手卡丢弃1张其他卡才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡在墓地存在的状态，超量怪兽被送去墓地的场合，把这张卡除外才能发动。从自己墓地把1只不死族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	-- 把墓地的这张卡除外作为发动②效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的下个回合的准备阶段，以自己场上1只不死族超量怪兽为对象才能发动。把除外状态的这张卡作为那只怪兽的超量素材。
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
-- 定义过滤器：卡可以丢弃（用于支付从手卡丢弃的代价）
function s.dcfilter(c)
	return c:IsDiscardable()
end
-- ①效果的代价处理：确认手卡中存在这张卡以外可以丢弃的卡，然后让玩家从手卡丢弃1张其他卡作为代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：手卡是否存在这张卡以外可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张这张卡以外的手卡作为代价
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果的目标处理：确认自己的主要怪兽区域有空位且这张卡可以从手卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己的主要怪兽区域还有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预计特殊召唤1张卡（即这张卡自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与该连锁相关，则把这张卡从手卡以表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤器：卡是超量怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_XYZ)
end
-- ②效果的发动条件：送去墓地的卡中存在超量怪兽，且不包含这张卡自身
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 定义过滤器：自己墓地的不死族怪兽且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标处理：确认墓地存在可以特殊召唤的不死族怪兽且自己的主要怪兽区域有空位
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查：自己墓地是否存在可以特殊召唤的不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
		-- 并且自己的主要怪兽区域还有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：预计从自己墓地特殊召唤1只怪兽（处理时才能确定是哪只）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理：确认主要怪兽区域有空位后，让玩家从自己墓地选1只不死族怪兽特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的主要怪兽区域没有空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只可以特殊召唤且不受「王家长眠之谷」影响的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件：当前回合是这张卡被除外的下个回合（回合数之差为1）
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否处于这张卡被除外的下个回合的准备阶段
	return Duel.GetTurnCount()-c:GetTurnID()==1
end
-- 定义过滤器：自己场上表侧表示的不死族超量怪兽
function s.matfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
-- ③效果的目标处理：确认自己场上存在可取为对象的不死族超量怪兽，且除外状态的这张卡可以作为超量素材
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc) end
	-- 发动时检查：自己场上是否存在可以成为对象的不死族超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只不死族超量怪兽作为效果的对象
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ③效果的处理：若这张卡与对象怪兽都仍与该连锁相关且对象不受效果影响，则把除外状态的这张卡作为那只怪兽的超量素材
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 把除外状态的这张卡叠放在对象怪兽下面作为其超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
