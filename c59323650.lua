--再世の龍神 ワイクラー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：场上有原本攻击力或原本守备力是2500的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己·对方回合，把这张卡解放，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
-- ③：这张卡被送去墓地的对方回合的结束阶段才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特召、二速解放除外魔陷、送墓后回合结束阶段回收三个效果。
function s.initial_effect(c)
	-- ①：场上有原本攻击力或原本守备力是2500的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡解放，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的对方回合的结束阶段才能发动。这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon2)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示存在且原本攻击力或原本守备力是2500的怪兽。
function s.cfilter(c)
	return (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500) and c:IsFaceup()
end
-- 手卡特殊召唤效果的条件判定函数。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的主要怪兽区域是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查双方场上是否存在至少1只满足过滤条件（原本攻防2500）的怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果②（除外魔陷）的发动代价判定与执行函数。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：可以被除外的魔法·陷阱卡。
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果②（除外魔陷）的目标选择与发动准备函数。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择对方场上1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：除外选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②（除外魔陷）的效果处理函数。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果③的送墓事件处理函数，在送去墓地时为自身注册一个持续到回合结束的Flag。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果③（回收手卡）的发动条件判定函数。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前是否为对方回合，且自身在当前回合被送去过墓地（带有Flag）。
	return Duel.GetTurnPlayer()==1-tp and e:GetHandler():GetFlagEffect(id)>0
end
-- 效果③（回收手卡）的发动准备函数。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息：将墓地的这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③（回收手卡）的效果处理函数。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，且不受王家长眠之谷的影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的这张卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
