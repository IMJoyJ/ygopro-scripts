--竜装合体 ドラゴニック・ホープレイ
-- 效果：
-- 5星怪兽×3
-- 这个卡名在规则上当作「混沌No.39 希望皇 霍普雷」使用。
-- ①：1回合1次，这张卡成为效果的对象时或者被选择作为攻击对象时才能发动。从手卡·卡组选1只「异热同心武器」怪兽当作那个效果的装备卡使用给这张卡装备。
-- ②：1回合1次，把这张卡1个超量素材取除，以最多有这张卡装备的「异热同心武器」怪兽卡数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果无效。
function c75402014.initial_effect(c)
	-- 设置XYZ召唤手续：5星怪兽×3
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，这张卡成为效果的对象时或者被选择作为攻击对象时才能发动。从手卡·卡组选1只「异热同心武器」怪兽当作那个效果的装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75402014,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c75402014.eqcon)
	e1:SetTarget(c75402014.eqtg)
	e1:SetOperation(c75402014.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除，以最多有这张卡装备的「异热同心武器」怪兽卡数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75402014,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c75402014.discost)
	e3:SetTarget(c75402014.distg)
	e3:SetOperation(c75402014.disop)
	c:RegisterEffect(e3)
end
-- 设置该卡（龙王霍普雷）的「No.」数值为39，用于判定相关辅助效果
aux.xyz_number[75402014]=39
-- 设置「混沌No.39 希望皇 霍普雷」的「No.」数值为39，用于判定相关辅助效果
aux.xyz_number[56840427]=39
-- 检查成为效果对象或攻击对象的卡中是否包含这张卡自身，作为装备效果的发动条件
function c75402014.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 过滤手卡·卡组中可以作为装备卡装备的「异热同心武器」怪兽
function c75402014.eqfilter(c,tp)
	return c.zw_equip_monster and c:IsSetCard(0x107e) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 装备效果的发动准备，检查魔法与陷阱区域是否有空位，以及手卡·卡组是否存在可装备的「异热同心武器」怪兽
function c75402014.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身魔法与陷阱区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自身的手卡·卡组中是否存在至少1只满足条件的「异热同心武器」怪兽
		and Duel.IsExistingMatchingCard(c75402014.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 装备效果的实际处理：从手卡·卡组选择1只「异热同心武器」怪兽给这张卡装备
function c75402014.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，若自身魔法与陷阱区域没有空位，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 提示玩家选择要装备的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从自身的手卡·卡组中选择1只满足条件的「异热同心武器」怪兽
		local g=Duel.SelectMatchingCard(tp,c75402014.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if not tc then return end
		tc.zw_equip_monster(tc,tp,c)
	end
end
-- 设定装备限制，使该装备卡只能装备给作为效果目标的这张卡
function c75402014.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果无效效果的代价处理：检查并取除这张卡的1个超量素材
function c75402014.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤这张卡装备的、原本是怪兽卡的表侧表示「异热同心武器」卡片
function c75402014.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107e) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 效果无效效果的发动准备，计算装备的「异热同心武器」数量，并选择对应数量的对方场上的表侧表示卡片作为对象
function c75402014.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 进行指向性效果的对象筛选，检查目标是否在对方场上且为可无效的表侧表示卡片
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	local ct=e:GetHandler():GetEquipGroup():FilterCount(c75402014.cfilter,nil)
	-- 检查自身装备的「异热同心武器」数量是否大于0，且对方场上是否存在至少1张可无效的卡片
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效效果的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择最多有装备的「异热同心武器」数量的对方场上的表侧表示卡片作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息，表明该效果的处理分类为使卡片效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- 过滤在效果处理时仍存在于场上、可被无效且仍与该效果相关的对象卡片
function c75402014.disfilter(c,e)
	-- 检查卡片是否符合无效化条件，且是否仍与当前发动的效果相关
	return aux.NegateAnyFilter(c) and c:IsRelateToEffect(e)
end
-- 效果无效效果的实际处理：使作为对象的卡片的效果无效
function c75402014.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象且满足无效化条件的卡片集合
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c75402014.disfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 使与目标卡片相关的连锁都无效化，在目标卡片被里侧表示放置时重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那些卡的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那些卡的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那些卡的效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
