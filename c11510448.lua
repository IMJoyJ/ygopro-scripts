--十二獣タイグリス
-- 效果：
-- 4星怪兽×3
-- 「十二兽 虎炮」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只超量怪兽和自己墓地1只「十二兽」怪兽为对象才能发动。那只「十二兽」怪兽在那只超量怪兽下面重叠作为超量素材。
function c11510448.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,3,c11510448.ovfilter,aux.Stringid(11510448,0),3,c11510448.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c11510448.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c11510448.defval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只超量怪兽和自己墓地1只「十二兽」怪兽为对象才能发动。那只「十二兽」怪兽在那只超量怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11510448,1))  --"补充超量素材"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c11510448.cost)
	e3:SetTarget(c11510448.target)
	e3:SetOperation(c11510448.operation)
	c:RegisterEffect(e3)
end
-- 该函数作为「十二兽 虎炮」在「十二兽」怪兽上面重叠来超量召唤时的替代条件：目标怪兽必须表侧表示、属于「十二兽」字段且不是「十二兽 虎炮」自身。
function c11510448.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(11510448)
end
-- 用于额外叠放召唤手续的操作函数：当选择在「十二兽」怪兽上面重叠召唤时，检查并登记本回合的1回合1次使用限制。若chk==0则判断可否使用；否则注册誓约标志，确保本回合不能再以该方式召唤。
function c11510448.xyzop(e,tp,chk)
	-- 检查当前玩家本回合是否尚未使用过「十二兽 虎炮」的替代超量召唤方式：若玩家身上的11510448号标志数量为0则允许使用。
	if chk==0 then return Duel.GetFlagEffect(tp,11510448)==0 end
	-- 为当前玩家注册一个持续到结束阶段的誓约标志（编号11510448），记录本回合已经使用过该召唤方式，防止1回合内重复使用。
	Duel.RegisterFlagEffect(tp,11510448,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 用于筛选超量素材中属于「十二兽」且攻击力数值有效的怪兽，只有这些怪兽的攻击力会被计入上升值。
function c11510448.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算攻击力上升值：取本卡叠放的素材中满足「十二兽」条件的怪兽，将其当前攻击力求和，作为攻击力上升量。
function c11510448.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c11510448.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 用于筛选超量素材中属于「十二兽」且守备力数值有效的怪兽，只有这些怪兽的守备力会被计入上升值。
function c11510448.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算守备力上升值：取本卡叠放的素材中满足「十二兽」条件的怪兽，将其当前守备力求和，作为守备力上升量。
function c11510448.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c11510448.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 发动代价：取除这张卡的1个超量素材。chk==0时检查是否有素材可取；实际发动时按代价取除1张素材。
function c11510448.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果目标1的筛选条件：自己场上表侧表示的超量怪兽，作为被叠放的目标。
function c11510448.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果目标2的筛选条件：自己墓地的「十二兽」怪兽，且该怪兽可以被作为超量素材叠放到超量怪兽下方。
function c11510448.filter2(c)
	return c:IsSetCard(0xf1) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 取对象效果的目标检查阶段：若在连锁处理中调用则直接拒绝；发动条件要求自己场上存在表侧超量怪兽且墓地存在可作为超量素材的「十二兽」怪兽。
function c11510448.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只表侧超量怪兽，作为第一个对象候补。
	if chk==0 then return Duel.IsExistingTarget(c11510448.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在至少1只可作为超量素材的「十二兽」怪兽，作为第二个对象候补。
		and Duel.IsExistingTarget(c11510448.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示本卡效果的发动（显示效果描述），用于让对方确认操作。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 显示选择提示文本“请选择1只超量怪兽”，引导玩家选择第一个对象。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11510448,2))  --"请选择1只超量怪兽"
	-- 选择自己场上1只表侧超量怪兽作为效果对象，并登记为连锁对象。
	Duel.SelectTarget(tp,c11510448.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示选择提示文本“请选择要作为超量素材的卡”，引导玩家选择第二个对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地1只「十二兽」怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c11510448.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：声明本连锁涉及墓地卡片移动（CATEGORY_LEAVE_GRAVE），对象为g并预计处理1张，使与此相关的效果能正确判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理时的追加过滤：确认目标怪兽仍在墓地且仍可作为超量素材，防止因效果转移或状态变化导致无法叠放。
function c11510448.opfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanOverlay()
end
-- 效果处理：从连锁对象中取出仍与效果关联的超量怪兽和墓地「十二兽」怪兽；若超量怪兽表侧且不免疫此效果，且墓地怪兽有效，则将墓地怪兽重叠到超量怪兽下方作为超量素材。
function c11510448.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的全部对象卡，并筛掉已经与效果失去联系的卡，避免把无效或离场过的对象作为处理对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc1=g:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local g2=g:Filter(c11510448.opfilter,nil)
	if tc1 and tc1:IsFaceup() and not tc1:IsImmuneToEffect(e) and g2:GetCount()>0 then
		-- 执行重叠操作：把选择的墓地「十二兽」怪兽叠放到目标超量怪兽下方，成为其超量素材。
		Duel.Overlay(tc1,g2)
	end
end
