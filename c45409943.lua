--宵闇のルーチェ
-- 效果：
-- 自己墓地的恶魔族·天使族怪兽×3
-- 自己主要怪兽区域左端和右端的怪兽不会被效果破坏。
-- 「日暮之暗 露彻」的以下效果1回合各能使用1次。
-- 可以以对方场上1张卡为对象；从卡组把1只恶魔族·天使族怪兽送去墓地，那张卡破坏。
-- 自己场上的其他卡被效果破坏的场合（伤害步骤除外）：可以以场上1张卡为对象；那张卡破坏。
local s,id,o=GetID()
-- 定义卡片初始效果函数
function s.initial_effect(c)
	-- 为卡片添加融合召唤手续，使用s.ffilter筛选3张恶魔族/天使族的墓地怪兽作为素材。
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- 创建第一个效果：从卡组送去墓地并破坏对方场上一张卡。设置效果描述、类别（破坏和送墓）、类型（起动）、发动地点（怪兽区）、属性（取对象）、次数限制（1次/回合），并注册该效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 创建第二个效果：当自己场上的其他卡被效果破坏时，可以破坏场上一张卡。设置效果描述、类别（破坏）、类型（场地诱发快速）、属性（取对象和延迟）、发动地点（怪兽区）、触发条件（EVENT_DESTROYED），次数限制（1次/回合），并注册该效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"场上的卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon2)
	e2:SetTarget(s.destg2)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
	-- 创建第三个效果：使自己主要怪兽区域左右两端的怪兽不会被效果破坏。设置效果类型为场地效果，代码为EFFECT_INDESTRUCTABLE_EFFECT，属性为可用于里侧状态的效果，发动地点为怪兽区，目标范围为怪兽区，目标函数为s.indtg，值为1，并注册该效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 定义筛选器函数s.ffilter：判断卡片是否为拥有者控制的、种族为恶魔/天使且在墓地的怪兽。
function s.ffilter(c,fc)
	return c:GetOwner()==fc:GetControler() and c:IsRace(RACE_FAIRY+RACE_FIEND)
		and c:IsLocation(LOCATION_GRAVE)
end
-- 定义筛选器函数s.tgfilter：判断卡片是否为恶魔/天使族的，并且可以送去墓地。
function s.tgfilter(c)
	return c:IsRace(RACE_FAIRY+RACE_FIEND) and c:IsAbleToGrave()
end
-- 定义目标选择函数s.destg：用于第一个效果的目标选择。检查连锁时是否有效，以及在确认模式下是否存在满足条件的卡牌和素材。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查当前回合是否有可作为目标的卡片存在于场上
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查卡组中是否存在符合条件的恶魔族/天使族的怪兽。
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择目标卡片。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将选定的卡片作为破坏的目标。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示将从卡组送去墓地一张恶魔族/天使族的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义效果操作函数s.desop：执行第一个效果的操作。获取目标卡片、提示玩家选择要送去墓地的卡片、从卡组选择并送去墓地的恶魔族/天使族怪兽，如果成功则破坏目标卡片。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择一张恶魔族/天使族的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 检查是否成功选择了卡片并将其送入墓地，以及目标卡片是否与连锁相关。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0
		and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		and tc:IsRelateToChain() then
		-- 破坏目标卡片。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义筛选器函数s.cfilter：判断卡片是否为之前的控制者控制、之前在场上且被效果破坏的卡片。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT)
end
-- 定义条件函数s.descon2：判断诱发效果是否可以发动，即是否存在满足s.cfilter条件的卡片。
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
-- 定义目标选择函数s.destg2：用于第二个效果的目标选择。检查连锁时是否有效，以及在确认模式下是否存在满足条件的卡牌。
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查当前回合是否有可作为目标的卡片存在于场上
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择目标卡片。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将选定的卡片作为破坏的目标。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果操作函数s.desop2：执行第二个效果的操作。获取目标卡片，如果目标卡片与连锁相关则将其破坏。
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 破坏目标卡片。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义目标函数s.indtg：判断卡片的序号是否为0或4（即左右两端的怪兽）。
function s.indtg(e,c)
	return c:GetSequence()==0 or c:GetSequence()==4
end
