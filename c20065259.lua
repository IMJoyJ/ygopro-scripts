--銃の忍者－火光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤·反转的场合才能发动。从自己的手卡·墓地选「铳之忍者-火光」以外的1只「忍者」怪兽里侧守备表示特殊召唤。
-- ②：这张卡在墓地存在，只以自己场上的「忍者」卡1张或者里侧守备表示怪兽1只为对象的对方的效果发动时才能发动。这张卡里侧守备表示特殊召唤，那张成为对象的卡回到持有者手卡。
local s,id,o=GetID()
-- 注册卡片的所有效果：①的召唤·特殊召唤·反转时诱发选发特殊召唤效果（e1/e2/e3），以及②的墓地中对方取对象效果发动时诱发的即时效果（e4）。
function s.initial_effect(c)
	-- 对应①效果中‘这张卡召唤的场合才能发动。从自己的手卡·墓地选「铳之忍者-火光」以外的1只「忍者」怪兽里侧守备表示特殊召唤。’（召唤成功时触发分支）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
	-- 对应②效果：‘这张卡在墓地存在，只以自己场上的「忍者」卡1张或者里侧守备表示怪兽1只为对象的对方的效果发动时才能发动。这张卡里侧守备表示特殊召唤，那张成为对象的卡回到持有者手牌。’
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
-- ①效果的选卡过滤：选择卡名不是「铳之忍者-火光」、属于「忍者」字段、且可以里侧守备表示特殊召唤的怪兽（从手牌·墓地）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and not c:IsCode(id)
end
-- ①效果的发动条件检查：自己主要怪兽区有空位，且手牌·墓地存在符合条件的「忍者」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手牌·墓地中是否存在1张以上满足 s.spfilter 过滤条件的「忍者」怪兽（可供特殊召唤）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本次效果处理将进行特殊召唤操作，预计从手牌·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ①效果处理：若场上仍有空位，从手牌·墓地选1只符合条件的「忍者」怪兽里侧守备表示特殊召唤，并让对方确认那只怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有主要怪兽区空位，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌·墓地选择1只满足条件且不受王家长眠之谷影响的「忍者」怪兽（里侧守备表示特殊召唤）。使用 aux.NecroValleyFilter 来排除受王谷影响的墓地特召。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认这张里侧特殊召唤的怪兽（因为里侧卡对方无法直接看到，需要公开确认）。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判定②是否满足：对方发动取对象效果，且该效果只以自己场上1张表侧表示的「忍者」卡或里侧守备表示怪兽为对象；若满足则将该对象记录到效果中备用。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动的那次连锁所取的对象卡。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsOnField() and tc:IsControler(tp)
		and (tc:IsFaceup() and tc:IsSetCard(0x2b)
			or tc:IsLocation(LOCATION_MZONE) and tc:IsPosition(POS_FACEDOWN_DEFENSE))
end
-- ②效果发动时进一步确认自己场上可用的怪兽区空位、墓地的这张卡能特殊召唤，且那个对象能回到手牌；满足后设为效果对象并登记特召/回手操作。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 发动时检查自己场上是否有可用的主要怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and tc and tc:IsAbleToHand() end
	-- 将对方效果的对象设为本次②效果的对象，使后续处理能正确关联。
	Duel.SetTargetCard(tc)
	-- 登记本次处理包含特殊召唤墓地的这张卡本身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 登记本次处理包含将对象卡返回持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- ②效果处理：若墓地中的这张卡仍与效果关联，将这张卡里侧守备表示特殊召唤，让对方确认；然后将之前成为对象的卡返回持有者手牌。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡已不与该效果关联（例如离场），或特殊召唤失败，则结束处理；否则继续。
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)==0 then return end
	-- 让对方确认被里侧守备特殊召唤的这张卡。
	Duel.ConfirmCards(1-tp,Group.FromCards(c))
	-- 取得本次②效果记录的对方效果对象卡（即将成为返回手牌对象的卡）。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与该效果关联，则将其返回持有者手牌。
	if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
