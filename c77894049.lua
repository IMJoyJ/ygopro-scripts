--VS ロックス
-- 效果：
-- 4星「征服斗魂」怪兽×2只以上
-- 「征服斗魂 洛克斯」在「征服斗魂」怪兽进行过战斗的回合有1次也能在自己场上的「征服斗魂」怪兽或「斗神的虚像」上面重叠来超量召唤。
-- ①：这张卡作为超量素材中的怪兽属性让这张卡得到以下效果。
-- ●暗：对方场上的怪兽的攻击力下降800。
-- ●炎：自己场上的「征服斗魂」怪兽的攻击力上升1000。
-- ●地：把这张卡1个超量素材取除才能发动。对方场上1张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含超量召唤手续、永续效果（暗、炎属性素材）、起动效果（地属性素材）以及用于记录战斗回合的全局监听器。
function s.initial_effect(c)
	-- 注册卡片关联密码，表明该卡效果文本中记载了「斗神的虚像」（卡号28168628）。
	aux.AddCodeList(c,28168628)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x195),4,2,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)  --"是否在「征服斗魂」怪兽或者「斗神的虚像」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ●暗：对方场上的怪兽的攻击力下降800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-800)
	e1:SetCondition(s.atkcon1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果2（炎属性素材效果）的影响对象为自己场上的「征服斗魂」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x195))
	e2:SetValue(1000)
	e2:SetCondition(s.atkcon2)
	c:RegisterEffect(e2)
	-- ●地：把这张卡1个超量素材取除才能发动。对方场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon3)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 「征服斗魂 洛克斯」在「征服斗魂」怪兽进行过战斗的回合有1次也能在自己场上的「征服斗魂」怪兽或「斗神的虚像」上面重叠来超量召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.checkop)
		-- 将全局监听效果注册给系统，用于在整局游戏中持续监听战斗事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤可用于重叠超量召唤的怪兽：自己场上表侧表示的「征服斗魂」怪兽或「斗神的虚像」。
function s.ovfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x195) or c:IsCode(28168628))
end
-- 检查超量素材中是否存在暗属性怪兽，作为暗属性效果的适用条件。
function s.atkcon1(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK)
end
-- 检查超量素材中是否存在炎属性怪兽，作为炎属性效果的适用条件。
function s.atkcon2(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
end
-- 检查超量素材中是否存在地属性怪兽，作为地属性效果的发动条件。
function s.atkcon3(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH)
end
-- 重叠超量召唤时的操作函数，检查本回合是否有「征服斗魂」怪兽进行过战斗，并注册本回合已使用过该方式超量召唤的全局标记。
function s.xyzop(e,tp,chk)
	-- 检查本回合是否有「征服斗魂」怪兽进行过战斗，且本回合自己尚未以此法进行过超量召唤。
	if chk==0 then return Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffect(tp,id+o)==0 end
	-- 给自己注册本回合已使用过该方式超量召唤的标记，该标记在回合结束时重置。
	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 检查怪兽是否为「征服斗魂」怪兽。
function s.check(c)
	return c and c:IsSetCard(0x195)
end
-- 战斗结束时的监听处理函数，若有「征服斗魂」怪兽参与了战斗，则为双方玩家注册本回合有「征服斗魂」怪兽进行过战斗的标记。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽或被攻击怪兽是否为「征服斗魂」怪兽。
	if s.check(Duel.GetAttacker()) or s.check(Duel.GetAttackTarget()) then
		-- 给自己注册本回合有「征服斗魂」怪兽进行过战斗的标记，回合结束时重置。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 给对方注册本回合有「征服斗魂」怪兽进行过战斗的标记，回合结束时重置。
		Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 地属性效果的发动代价：取除这张卡的1个超量素材。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 地属性效果的发动准备：检查对方场上是否存在卡片，并设置破坏效果的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡片。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息：从获取的卡片组中破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 地属性效果的效果处理：让发动效果的玩家选择对方场上1张卡破坏。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否仍有卡片存在。
	if Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从对方场上选择1张卡。
		local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 为选中的卡片显示被选为对象的动画效果。
		Duel.HintSelection(g2)
		-- 破坏选中的卡片。
		Duel.Destroy(g2,REASON_EFFECT)
	end
end
