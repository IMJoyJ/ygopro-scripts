--閃刀姫－アザレア・テンペランス
-- 效果：
-- 包含连接怪兽的怪兽2只以上
-- 这张卡不用连接召唤不能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合，从自己的手卡·墓地把1张魔法卡除外，以对方场上1只攻击力2500以下的怪兽为对象才能发动。那只表侧表示怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡被战斗破坏时才能发动。从自己的手卡·墓地把这张卡以外的1只「闪刀」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包括连接召唤手续、特殊召唤限制、特殊召唤成功时装备对方怪兽的效果，以及被战斗破坏时特殊召唤手卡·墓地「闪刀」怪兽的效果。
function s.initial_effect(c)
	-- 添加连接召唤手续：需要2-3只怪兽作为素材，且必须满足s.lcheck过滤条件。
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- 这张卡不用连接召唤不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤限制为仅能通过连接召唤从额外卡组特殊召唤。
	e1:SetValue(aux.linklimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合，从自己的手卡·墓地把1张魔法卡除外，以对方场上1只攻击力2500以下的怪兽为对象才能发动。那只表侧表示怪兽当作装备魔法卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"当作装备"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.eqcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗破坏时才能发动。从自己的手卡·墓地把这张卡以外的1只「闪刀」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤连接素材，要求用于连接召唤的素材组中必须包含至少1只连接怪兽。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 过滤可以作为cost除外的卡：必须是魔法卡，且可以被除外。
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 效果①的Cost处理：检查并从自己的手卡或墓地选择1张魔法卡除外。
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在至少1张满足过滤条件的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从手卡或墓地选择1张满足过滤条件的魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡片表侧表示除外作为发动Cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤可以作为装备对象的怪兽：必须是表侧表示、攻击力在2500以下，且可以转移控制权。
function s.eqfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(2500) and c:IsAbleToChangeControler()
end
-- 效果①的Target处理：检查魔法与陷阱区域是否有空位，并选择对方场上1只符合条件的怪兽作为对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.eqfilter(chkc) end
	-- 检查自己场上的魔法与陷阱区域是否有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在可以作为对象的、攻击力2500以下的表侧表示怪兽。
		and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择对方场上1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的Operation处理：将选中的对象怪兽作为装备卡装备给这张卡，并添加装备限制。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①锁定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍表侧表示存在且与效果有关联，将其作为装备卡装备给这张卡。
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c,false) then
		-- 当作装备魔法卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制过滤函数：该装备卡只能装备给此效果的发动者（即这张卡）。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤可以特殊召唤的「闪刀」怪兽：必须是「闪刀」字段且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target处理：检查怪兽区域是否有空位，并确认手卡或墓地是否存在除自身以外的「闪刀」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在除这张卡以外的、可以特殊召唤的「闪刀」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁信息，表明该效果包含从手卡或墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的Operation处理：从手卡或墓地选择1只除这张卡以外的「闪刀」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或墓地选择1张除这张卡以外的、满足条件的「闪刀」怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,aux.ExceptThisCard(e),e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
