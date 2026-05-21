--天地晦冥
-- 效果：
-- 这个卡名在规则上也当作「忍法」卡使用。
-- ①：自己的「忍者」怪兽给与对方战斗伤害时，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：场地区域的表侧表示的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合，以自己墓地的「忍者」怪兽任意数量为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①效果（战斗伤害时破坏对方卡片）、②效果（因对方效果离场送墓/除外时里侧特召墓地忍者怪兽）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己的「忍者」怪兽给与对方战斗伤害时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：场地区域的表侧表示的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合，以自己墓地的「忍者」怪兽任意数量为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 判定①效果的发动条件：造成战斗伤害的玩家是对方，且造成伤害的怪兽是由自己控制的「忍者」怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsSetCard(0x2b)
end
-- ①效果的发动准备与对象选择：检查对方场上是否存在可作为对象的卡，并进行取对象操作及设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可以作为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择对方场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理的操作信息，表示此效果将破坏选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的实际处理：获取选中的对象，若该卡仍符合条件则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡在效果处理时仍与该效果相关联，则将其因效果破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 判定②效果的发动条件：此卡因对方的效果从场上离开，且离开前是自己控制的场地区域表侧表示的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(c:GetOwner()) and c:IsPreviousLocation(LOCATION_FZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_EFFECT)
end
-- 过滤出墓地中可以作为效果对象、且能以里侧守备表示特殊召唤的「忍者」怪兽。
function s.filter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果的发动准备与对象选择：检查自身怪兽区域是否有空位，以及墓地中是否存在符合条件的「忍者」怪兽，并选择任意数量（同名卡最多1张）的怪兽作为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地中是否存在至少1只符合条件的「忍者」怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取自己场上可用的怪兽区域空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中筛选符合条件的「忍者」怪兽，并让玩家选择不超过空位数且卡名互不相同的任意数量的卡。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp):SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将玩家选择的卡片组设为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	-- 设置连锁处理的操作信息，表示此效果将特殊召唤选中的所有怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
-- ②效果的实际处理：获取仍有效的对象，在满足怪兽区域空位和特殊召唤限制（如青眼精灵龙）的情况下，将这些怪兽里侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用的怪兽区域空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中仍与该效果相关联的对象卡片组。
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if #sg>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #sg>ft then
		-- 提示玩家选择要特殊召唤的卡（用于当对象数量超过当前可用空格数时进行二次筛选）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
end
