--「RESORT」 STAFF－チャーミング
-- 效果：
-- ①：自己的「秘旋谍-花公子」和对方的表侧表示怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽的攻击力变成0。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「秘旋谍-花公子」特殊召唤。
-- ③：这张卡在墓地存在，自己场上的表侧表示的「秘旋谍-花公子」被战斗破坏的场合或者被送去墓地的场合，把墓地的这张卡除外才能发动。选自己墓地1只「秘旋谍-花公子」加入手卡。
function c64753157.initial_effect(c)
	-- ①：自己的「秘旋谍-花公子」和对方的表侧表示怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64753157,0))  --"对方怪兽的攻击力变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c64753157.atkcon)
	e1:SetTarget(c64753157.atktg)
	e1:SetOperation(c64753157.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「秘旋谍-花公子」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64753157,1))  --"从卡组把「秘旋谍-花公子」特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c64753157.spcon)
	e2:SetTarget(c64753157.sptg)
	e2:SetOperation(c64753157.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在，自己场上的表侧表示的「秘旋谍-花公子」被战斗破坏的场合或者被送去墓地的场合，把墓地的这张卡除外才能发动。选自己墓地1只「秘旋谍-花公子」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64753157,2))  --"墓地的「秘旋谍-花公子」回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c64753157.thcon)
	-- 把墓地的这张卡除外作为发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c64753157.thtg)
	e3:SetOperation(c64753157.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e4)
end
-- 检查是否是自己的「秘旋谍-花公子」与对方的表侧表示怪兽进行战斗的攻击宣言时，并将对方怪兽保存为标签对象
function c64753157.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d or a:GetControler()==d:GetControler() or d:IsFacedown() or a:IsFacedown() then return end
	if a:IsControler(tp) and a:IsCode(41091257) then e:SetLabelObject(d)
	elseif d:IsControler(tp) and d:IsCode(41091257) then e:SetLabelObject(a)
	else return false end
	return true
end
-- 效果1的目标选择函数，确认保存的对方怪兽是否在场，并将其设为效果处理的对象
function c64753157.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc:IsOnField() end
	-- 将该对方怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(tc)
end
-- 效果1的操作函数，使作为对象的对方怪兽的攻击力变成0
function c64753157.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的第一个效果处理对象（即那只对方怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) then
		-- 那只对方怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 检查这张卡是否是被战斗或效果破坏
function c64753157.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤卡组中可以特殊召唤的「秘旋谍-花公子」
function c64753157.spfilter(c,e,tp)
	return c:IsCode(41091257) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的目标选择函数，确认自己场上有怪兽区域空位且卡组中存在可特殊召唤的「秘旋谍-花公子」，并设置特殊召唤的操作信息
function c64753157.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「秘旋谍-花公子」
		and Duel.IsExistingMatchingCard(c64753157.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果2的操作函数，从卡组将1只「秘旋谍-花公子」特殊召唤
function c64753157.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取卡组中第1只满足特殊召唤条件的「秘旋谍-花公子」
	local tg=Duel.GetFirstMatchingCard(c64753157.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tg then
		-- 将选定的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤原本在自己场上表侧表示存在、现在被破坏或送去墓地的「秘旋谍-花公子」
function c64753157.cfilter(c,tp)
	return c:IsCode(41091257) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果3的条件检查函数，检查这张卡自身不在被破坏/送墓的卡中，且自己场上表侧表示的「秘旋谍-花公子」被战斗破坏或送去墓地
function c64753157.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c64753157.cfilter,1,nil,tp)
end
-- 过滤自己墓地中可以加入手牌的「秘旋谍-花公子」
function c64753157.thfilter(c)
	return c:IsCode(41091257) and c:IsAbleToHand()
end
-- 效果3的目标选择函数，确认自己墓地中存在可加入手牌的「秘旋谍-花公子」，并设置加入手牌的操作信息
function c64753157.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在至少1只可以加入手牌的「秘旋谍-花公子」
	if chk==0 then return Duel.IsExistingMatchingCard(c64753157.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置当前连锁的操作信息为：从墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果3的操作函数，选自己墓地1只「秘旋谍-花公子」加入手牌
function c64753157.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的「秘旋谍-花公子」
	local g=Duel.SelectMatchingCard(tp,c64753157.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
