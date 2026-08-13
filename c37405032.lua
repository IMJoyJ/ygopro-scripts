--トリックスター・アクアエンジェル
-- 效果：
-- 这个卡名在规则上也当作「海晶少女」卡使用。这个卡名的①③的效果在决斗中各能使用1次。
-- ①：自己场上有「淘气仙星」怪兽或「海晶少女」怪兽存在的场合才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：有这张卡位于所连接区的连接怪兽不会被战斗破坏。
-- ③：这张卡作为连接素材送去墓地的场合才能发动。对方的手卡·场上（里侧表示）的卡全部确认。
local s,id,o=GetID()
-- 注册三个效果：①起动效果（从手卡/墓地特殊召唤）、②永续效果（所连接区的连接怪兽不会被战斗破坏）、③诱发选发效果（作为连接素材送墓时确认对方手牌和里侧卡）；其中①③效果在决斗中各能使用1次。
function s.initial_effect(c)
	-- ①：自己场上有「淘气仙星」怪兽或「海晶少女」怪兽存在的场合才能发动。这张卡从手卡·墓地特殊召唤。（这个卡名的①③的效果在决斗中各能使用1次。）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：有这张卡位于所连接区的连接怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTarget(s.latktg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡作为连接素材送去墓地的场合才能发动。对方的手卡·场上（里侧表示）的卡全部确认。（这个卡名的①③的效果在决斗中各能使用1次。）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o+EFFECT_COUNT_CODE_DUEL)
	e3:SetCondition(s.cfcon)
	e3:SetTarget(s.cftg)
	e3:SetOperation(s.cfop)
	c:RegisterEffect(e3)
end
-- 筛选条件：怪兽为表侧表示，且卡名属于「淘气仙星」或「海晶少女」系列（对应规则上的双重系列名）。
function s.cfilter(c)
	return c:IsSetCard(0xfb,0x12b) and c:IsFaceup()
end
-- ①效果的发动条件：检查自己场上是否存在至少1只表侧表示的「淘气仙星」或「海晶少女」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否存在至少1张满足上述筛选条件的卡，即自己场上有表侧表示的相关系列怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动时的合法性检查：获取效果持有者（这张卡），确认自己主要怪兽区有空位，且这张卡能被自己通过效果特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否存在可用的空位（特殊召唤所需）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设定为特殊召唤这张卡（数量1），供其他效果或规则判断使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与发动效果关联，则将其表侧表示特殊召唤到己方场上（正常检查召唤条件和苏生限制）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到 tp 玩家场上，返回实际特殊召唤成功的数量。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的目标判定：该怪兽是连接怪兽，且位于这张卡（效果持有者）的连接区。
function s.latktg(e,c)
	return c:IsType(TYPE_LINK) and c:GetLinkedGroup():IsContains(e:GetHandler())
end
-- ③效果的发动条件：这张卡作为连接素材送去墓地（r==REASON_LINK），且当前位于墓地。
function s.cfcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- ③效果发动时的检查：对方手牌中存在非公开的卡，或对方场上有里侧表示的卡，满足其一即可发动。
function s.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 查询对方手牌中是否存在非公开状态的卡，或对方场上是否存在里侧表示卡（存在即满足③发动条件）。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 筛选要确认的卡：位于手牌的卡，或场上里侧表示的卡。
function s.cffilter(c)
	return c:IsLocation(LOCATION_HAND) or c:IsFacedown()
end
-- ③效果处理：获取对方场上与手牌的全部卡，筛选出其中的手牌和里侧表示卡，让己方确认这些卡，然后洗切对方手牌。
function s.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上（含里侧）和手牌的全部卡片组 g。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
	if g:GetCount()>0 then
		local cg=g:Filter(s.cffilter,nil)
		-- 将筛选出的卡组 cg 展示给己方玩家 tp 确认（对应确认对方手牌及里侧卡）。
		Duel.ConfirmCards(tp,cg)
		-- 洗切对方玩家（1-tp）的手牌（规则上确认后需洗牌）。
		Duel.ShuffleHand(1-tp)
	end
end
