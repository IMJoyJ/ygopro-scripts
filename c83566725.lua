--幻影騎士団ドゥームソルレット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「幻影骑士团」魔法·陷阱卡在自己场上盖放。
-- ③：把墓地的这张卡除外，以自己场上最多2只3星·3阶的暗属性怪兽为对象才能发动。那些怪兽的等级·阶级上升1。
local s,id,o=GetID()
-- 初始化卡片效果，注册特殊召唤规则、召唤或特殊召唤成功时盖放魔法·陷阱卡的效果以及墓地除外升星的效果
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「幻影骑士团」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放魔陷"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，以自己场上最多2只3星·3阶的暗属性怪兽为对象才能发动。那些怪兽的等级·阶级上升1。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"上升等级·阶级"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	-- 将自身作为发动成本从墓地表侧表示除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end
-- 定义手卡特殊召唤规则的条件判定函数
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己场上是否有空怪兽区域且没有怪兽存在
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤卡组中可盖放的「幻影骑士团」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x10db) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 定义盖放魔陷效果的对象选择与合法性检查函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前确认卡组中存在可盖放的「幻影骑士团」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义盖放魔陷效果的执行操作函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组选择1张符合条件的「幻影骑士团」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的魔法·陷阱卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 过滤自己场上表侧表示的3星或3阶暗属性怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
		and (c:IsLevel(3) or c:IsRank(3))
end
-- 定义等级/阶级上升效果的对象选择与合法性检查函数
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	-- 效果发动前确认场上是否存在符合条件的3星或3阶暗属性怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要发动效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择最多2只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,2,nil)
end
-- 过滤效果处理时仍存在于场上且仍与连锁关系相符的被选择卡片
function s.cfilter(c)
	return c:IsFaceup() and c:IsRelateToChain()
end
-- 定义等级/阶级上升效果的执行操作函数
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁被选作对象的怪兽并过滤保留目前仍有效的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.cfilter,nil)
	-- 遍历所有被选择且依然有效的卡
	for tc in aux.Next(g) do
		-- 那些怪兽的等级·阶级上升1。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		if tc:IsLevelAbove(1) then
			e1:SetCode(EFFECT_UPDATE_LEVEL)
		else
			e1:SetCode(EFFECT_UPDATE_RANK)
		end
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
