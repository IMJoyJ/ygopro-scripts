--No.72 ラインモンスター チャリオッツ・飛車
-- 效果：
-- 6星怪兽×2
-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1只表侧表示怪兽和对方场上盖放的1张魔法·陷阱卡为对象才能发动。那些卡破坏。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成一半。
function c75253697.initial_effect(c)
	-- 添加XYZ召唤手续：6星怪兽×2
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1只表侧表示怪兽和对方场上盖放的1张魔法·陷阱卡为对象才能发动。那些卡破坏。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75253697,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c75253697.descost)
	e1:SetTarget(c75253697.destg)
	e1:SetOperation(c75253697.desop)
	c:RegisterEffect(e1)
end
-- 设定该卡为“No.”怪兽，其卡号为72
aux.xyz_number[75253697]=72
-- 效果发动代价（Cost）处理：检查并取除这张卡的2个超量素材
function c75253697.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤函数：筛选表示形式为指定表示形式（表侧表示或盖放/里侧表示）的卡片
function c75253697.dfilter(c,pos)
	return c:IsPosition(pos)
end
-- 效果发动目标（Target）处理：检查并选择对方场上1只表侧表示怪兽和对方场上1张盖放的魔陷卡作为对象
function c75253697.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c75253697.dfilter,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP)
		-- 检查对方场上是否存在至少1张盖放的魔法·陷阱卡
		and Duel.IsExistingTarget(c75253697.dfilter,tp,0,LOCATION_SZONE,1,nil,POS_FACEDOWN) end
	-- 给发动效果的玩家发送提示信息：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c75253697.dfilter,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP)
	-- 给发动效果的玩家发送提示信息：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张盖放的魔法·陷阱卡作为效果对象
	local g2=Duel.SelectTarget(tp,c75253697.dfilter,tp,0,LOCATION_SZONE,1,1,nil,POS_FACEDOWN)
	g1:Merge(g2)
	-- 设置连锁信息，表明该效果的操作分类为“破坏”，涉及卡片数量为2张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果运行（Operation）处理：破坏作为对象的卡，并使对方受到的战斗伤害直到回合结束时变成一半
function c75253697.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍存在于场上且与效果相关的对象卡片破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时对方受到的战斗伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该全局效果，使对方受到的战斗伤害减半的效果生效
	Duel.RegisterEffect(e1,tp)
end
