--リブロマンサー・デスブローカー
-- 效果：
-- 「书灵师」卡降临。这个卡名的②③的效果1回合各能使用1次。
-- ①：使用场上的怪兽作仪式召唤的这张卡可以直接攻击。
-- ②：自己主要阶段才能发动。从卡组选1张「书灵师」陷阱卡在自己的魔法与陷阱区域盖放。
-- ③：这张卡给与对方战斗伤害时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽回到持有者卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含仪式召唤限制、素材检查、直接攻击、卡组盖放陷阱、战斗伤害时让对方怪兽回卡组的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：使用场上的怪兽作仪式召唤的这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- ①：使用场上的怪兽作仪式召唤的这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.matcon)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从卡组选1张「书灵师」陷阱卡在自己的魔法与陷阱区域盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- ③：这张卡给与对方战斗伤害时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽回到持有者卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.f2dcon)
	e4:SetTarget(s.f2dtg)
	e4:SetOperation(s.f2dop)
	c:RegisterEffect(e4)
end
-- 仪式召唤素材检查，若使用了场上的怪兽，则给这张卡注册一个带有客户端提示的标记
function s.matcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		local reset=RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD
		c:RegisterFlagEffect(id,reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))  --"使用场上的怪兽作仪式召唤"
	end
end
-- 检查这张卡是否是仪式召唤登场，且在仪式召唤时使用了场上的怪兽作为素材
function s.matcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:GetFlagEffect(id)>0
end
-- 过滤条件：卡组中属于「书灵师」系列、且是陷阱卡、并且可以盖放的卡
function s.setfilter(c)
	return c:IsSetCard(0x17c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果②盖放陷阱的发动条件与目标选择，检查卡组中是否存在可盖放的「书灵师」陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的「书灵师」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②盖放陷阱的效果处理，从卡组选择1张「书灵师」陷阱卡在自己的魔法与陷阱区域盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足条件的「书灵师」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,g)
	end
end
-- 效果③的发动条件：这张卡给与对方玩家战斗伤害时
function s.f2dcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 效果③回卡组的发动条件与目标选择，确认对方场上是否存在可以回到卡组的表侧表示怪兽，并进行取对象和设置操作信息
function s.f2dtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsAbleToDeck() end
	-- 检查对方场上是否存在至少1只可以回到卡组的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsFaceup,Card.IsAbleToDeck),tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择对方场上1只可以回到卡组的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsFaceup,Card.IsAbleToDeck),tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息，表示该效果包含将选中的1张卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果③回卡组的效果处理，将作为对象的怪兽回到持有者卡组并洗牌
function s.f2dop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
