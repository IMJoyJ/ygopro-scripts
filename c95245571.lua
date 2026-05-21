--肆世壊の双牙
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只「恐吓爪牙族」怪兽解放，以对方场上2张卡为对象才能发动。那些卡破坏。自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，这个效果破坏的卡不去墓地而除外。
-- ②：场上有连接3以上的怪兽存在的场合，把墓地的这张卡除外才能发动。这个回合，场上的连接怪兽不能把效果发动。
function c95245571.initial_effect(c)
	-- 注册卡片记有「维萨斯-斯塔弗罗斯特」卡名的信息
	aux.AddCodeList(c,56099748)
	-- ①：把自己场上1只「恐吓爪牙族」怪兽解放，以对方场上2张卡为对象才能发动。那些卡破坏。自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，这个效果破坏的卡不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95245571,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,95245571+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c95245571.cost)
	e1:SetTarget(c95245571.target)
	e1:SetOperation(c95245571.activate)
	c:RegisterEffect(e1)
	-- ②：场上有连接3以上的怪兽存在的场合，把墓地的这张卡除外才能发动。这个回合，场上的连接怪兽不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95245571,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_DRAW_PHASE)
	e2:SetCondition(c95245571.cacon)
	-- 设置发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c95245571.catg)
	e2:SetOperation(c95245571.caop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价处理函数，设置Label标记以在target中处理解放怪兽的代价
function c95245571.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤条件：场上表侧表示的「维萨斯-斯塔弗罗斯特」
function c95245571.actfilter(c)
	return c:IsCode(56099748) and c:IsFaceup()
end
-- 过滤条件：可破坏的对象（若「维萨斯-斯塔弗罗斯特」在场则对象必须能被除外）
function c95245571.desfilter(c,check)
	return check or c:IsAbleToRemove()
end
-- 过滤条件：不能是被解放的怪兽或此卡自身，且满足破坏过滤条件的对象
function c95245571.descfilter(c,tc,ec,check)
	return c95245571.desfilter(c,check) and c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤条件：场上可解放的「恐吓爪牙族」怪兽，且解放后对方场上仍存在2张可破坏的对象
function c95245571.costfilter(c,ec,tp,check)
	if not c:IsSetCard(0x17a) then return false end
	-- 检查对方场上是否存在2张满足条件的可选择对象
	return Duel.IsExistingTarget(c95245571.descfilter,tp,0,LOCATION_ONFIELD,2,c,c,ec,check)
end
-- ①效果的靶向与代价处理函数，处理解放怪兽并选择对方场上2张卡作为对象
function c95245571.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查自己场上是否不存在「维萨斯-斯塔弗罗斯特」
	local check=not Duel.IsExistingMatchingCard(c95245571.actfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if chkc then return chkc:IsOnField() and chkc~=c and c95245571.desfilter(chkc,check) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在可解放的「恐吓爪牙族」怪兽
			return Duel.CheckReleaseGroup(tp,c95245571.costfilter,1,c,c,tp,check)
		else
			-- 检查对方场上是否存在2张可作为破坏对象的卡
			return Duel.IsExistingTarget(c95245571.desfilter,tp,0,LOCATION_ONFIELD,2,c,check)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择自己场上1只「恐吓爪牙族」怪兽解放
		local sg=Duel.SelectReleaseGroup(tp,c95245571.costfilter,1,1,c,c,tp,check)
		-- 解放选择的怪兽作为发动代价
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上2张卡作为效果对象
	local g=Duel.SelectTarget(tp,c95245571.desfilter,tp,0,LOCATION_ONFIELD,2,2,c,check)
	-- 设置效果处理信息为破坏这2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- ①效果的空间处理函数，破坏对象卡片，若「维萨斯-斯塔弗罗斯特」在场则将其除外
function c95245571.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检查自己场上是否存在「维萨斯-斯塔弗罗斯特」
	if Duel.IsExistingMatchingCard(c95245571.actfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 破坏这些卡并将其除外（不去墓地而除外）
		Duel.Destroy(sg,REASON_EFFECT,LOCATION_REMOVED)
	else
		-- 破坏这些卡（送去墓地）
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- ②效果的发动条件判定函数，检查场上是否存在连接3以上的怪兽
function c95245571.cacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在连接3以上的怪兽
	return Duel.IsExistingMatchingCard(Card.IsLinkAbove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,3)
end
-- ②效果的靶向判定函数，检查本回合是否已注册过该限制效果
function c95245571.catg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定本回合是否尚未适用过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,95245571)==0 end
end
-- ②效果的空间处理函数，适用「本回合场上的连接怪兽不能把效果发动」的限制
function c95245571.caop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，场上的连接怪兽不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c95245571.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该限制效果
	Duel.RegisterEffect(e1,tp)
	-- 给玩家注册本回合已发动该效果的标记
	Duel.RegisterFlagEffect(tp,95245571,RESET_PHASE+PHASE_END,0,1)
end
-- 限制发动效果的过滤函数：场上的连接怪兽的怪兽效果
function c95245571.aclimit(e,re,tp)
	local c=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_MZONE)
end
