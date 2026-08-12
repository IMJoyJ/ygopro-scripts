--レッドアイズ・ブラックフルメタルドラゴン
-- 效果：
-- 这张卡不能通常召唤，用把5星以上的龙族怪兽解放发动的「金属化·强化反射装甲」的效果可以特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放，这张卡回到卡组。
-- ②：对方把效果发动时才能发动。那个发动无效。那之后，可以给与对方为对方场上1只攻击表示怪兽的原本攻击力数值的伤害。
local s,id,o=GetID()
-- 初始化并注册卡片效果
function s.initial_effect(c)
	-- 将「金属化·强化反射装甲」（卡号89812483）加入该卡的关联卡片列表
	aux.AddCodeList(c,89812483)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放「金属化」陷阱卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时才能发动。那个发动无效。那之后，可以给与对方为对方场上1只攻击表示怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 过滤条件：用于判定是否为解放所需的5星以上的龙族怪兽
function s.mfilter(ft,lv,race,att)
	return ft==1 and lv>=5 and bit.band(race,RACE_DRAGON)==RACE_DRAGON
end
s.Metallization_material=s.mfilter
-- ①效果的发动代价：将手牌的这张卡给对方观看
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件：卡组中属于「金属化」系列且可以盖放的陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动准备：检查魔陷区空位、卡组中是否存在可盖放的「金属化」陷阱卡以及自身是否能回到卡组
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的魔陷区空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的「金属化」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		and c:IsAbleToDeck() end
end
-- ①效果的效果处理：从卡组盖放1张「金属化」陷阱卡，并将这张卡回到卡组
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此时魔陷区没有空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足条件的「金属化」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功盖放该卡且手牌的这张卡仍适用该效果，则执行后续处理
	if tc and Duel.SSet(tp,tc)~=0 and c:IsRelateToEffect(e) then
		-- 将这张卡回到持有者卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：此卡未被战斗破坏、对方发动效果且该发动可以被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否未被战斗破坏、发动效果的玩家是否为对方以及该连锁的发动是否可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and Duel.IsChainNegatable(ev)
end
-- 过滤条件：原本攻击力大于0且处于表侧攻击表示的怪兽
function s.damfilter(c)
	return c:GetBaseAttack()>0 and c:IsPosition(POS_FACEUP_ATTACK)
end
-- ②效果的发动准备：设置无效发动的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将该连锁的发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果的效果处理：使发动无效，并可以选对方场上1只表侧攻击表示怪兽给予对方其原本攻击力数值的伤害
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且对方场上存在符合条件的怪兽，且玩家选择发动追加伤害效果
	if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(s.damfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再给予伤害"
		-- 中断当前效果处理，使后续的伤害处理不与无效处理同时进行
		Duel.BreakEffect()
		-- 提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择对方场上1只符合条件的表侧攻击表示怪兽
		local g=Duel.SelectMatchingCard(tp,s.damfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		-- 为选中的怪兽显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 给予对方该怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
