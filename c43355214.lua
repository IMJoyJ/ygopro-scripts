--不死の大軍団
-- 效果：
-- 7星怪兽×2
-- 「不死者军团」1回合1次也能在自己场上的6阶不死族超量怪兽上面重叠来超量召唤。
-- 对方主要阶段（诱发即时效果）：可以把这张卡2个超量素材取除（这张卡只有超量怪兽在作为超量素材的场合，取除的超量素材数量可以变成1个），以对方场上1只表侧攻击表示怪兽或者对方墓地1只怪兽为对象；那只怪兽作为这张卡的超量素材。
-- 「不死者军团」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 为卡片添加超量召唤手续，允许在6阶不死族怪兽上重叠召唤
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在6阶不死族超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 诱发即时效果，可以在对方主要阶段发动，将目标怪兽作为超量素材
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"作为超量素材"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 筛选场上6阶不死族怪兽的过滤条件
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(6) and c:IsRace(RACE_ZOMBIE)
end
-- 设置超量召唤时的标志效果，防止一回合多次使用
function s.xyzop(e,tp,chk)
	-- 检查是否已使用过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册全局标识效果，用于限制一回合只能使用一次
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 支付超量素材的费用，根据是否有非超量怪兽决定取除数量
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local minct=2
	-- 判断是否存在非超量怪兽作为超量素材
	if not g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_XYZ) then
		minct=1
	end
	if chk==0 then return c:CheckRemoveOverlayCard(tp,minct,REASON_COST) end
	c:RemoveOverlayCard(tp,minct,2,REASON_COST)
end
-- 筛选可作为超量素材的目标怪兽条件
function s.filter(c)
	return (c:IsPosition(POS_FACEUP_ATTACK) or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 判断是否为对方主要阶段且不是自己回合
function s.con(e,tp,eg,ep,ev,re,r,rp)
	-- 对方主要阶段且不是自己回合时效果可用
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 设置效果目标选择，优先从场上选择攻击表示怪兽或墓地怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从场上或墓地选择目标怪兽作为超量素材
	local g=aux.SelectTargetFromFieldFirst(tp,s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 设置操作信息，标记将要离开墓地的卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 执行效果操作，将目标怪兽叠放至自身上
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain()
		-- 判断目标怪兽是否能被叠放且未免疫该效果
		and not tc:IsImmuneToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanOverlay() and aux.NecroValleyFilter()(tc) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将目标怪兽身上的叠放卡送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标怪兽作为超量素材叠放至自身
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
