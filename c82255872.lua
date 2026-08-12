--戦華史略－大丈夫之義
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：对方对怪兽的特殊召唤成功的场合才能发动。在自己场上把1只「战华的龙兵衍生物」（兽战士族·风·1星·攻/守500）特殊召唤。
-- ②：自己·对方的「战华」怪兽被战斗破坏的场合，可以作为代替把这张卡送去墓地。
-- ③：场上的「战华」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效。
function c82255872.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方对怪兽的特殊召唤成功的场合才能发动。在自己场上把1只「战华的龙兵衍生物」（兽战士族·风·1星·攻/守500）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82255872,0))
	e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,82255872)
	e2:SetCondition(c82255872.tkcon)
	e2:SetTarget(c82255872.tktg)
	e2:SetOperation(c82255872.tkop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的「战华」怪兽被战斗破坏的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c82255872.reptg)
	e3:SetValue(c82255872.repval)
	e3:SetOperation(c82255872.repop)
	c:RegisterEffect(e3)
	-- ③：场上的「战华」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82255872,1))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCountLimit(1,82255873)
	e4:SetCondition(c82255872.negcon)
	-- 设置发动代价为把墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c82255872.negtg)
	e4:SetOperation(c82255872.negop)
	c:RegisterEffect(e4)
end
-- 过滤条件：由对方特殊召唤的怪兽
function c82255872.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 效果①的发动条件：对方对怪兽的特殊召唤成功
function c82255872.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82255872.cfilter,1,nil,tp)
end
-- 效果①的靶向与可行性检查
function c82255872.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的「战华的龙兵衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,82255873,0x137,TYPES_TOKEN_MONSTER,500,500,1,RACE_BEASTWARRIOR,ATTRIBUTE_WIND) end
	-- 设置连锁处理的操作信息：产生衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理的操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的效果处理（特殊召唤衍生物）
function c82255872.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若仍满足特殊召唤该衍生物的条件
	if Duel.IsPlayerCanSpecialSummonMonster(tp,82255873,0x137,TYPES_TOKEN_MONSTER,500,500,1,RACE_BEASTWARRIOR,ATTRIBUTE_WIND) then
		-- 创建「战华的龙兵衍生物」卡片数据
		local token=Duel.CreateToken(tp,82255873)
		-- 将衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示的、因战斗被破坏的「战华」怪兽
function c82255872.repfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE)
		and c:IsSetCard(0x137) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的靶向与可行性检查
function c82255872.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c82255872.repfilter,1,nil) end
	-- 询问玩家是否使用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏的适用对象
function c82255872.repval(e,c)
	return c82255872.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的具体操作（将此卡送去墓地）
function c82255872.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- 过滤条件：场上表侧表示的「战华」怪兽
function c82255872.tfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0x137)
end
-- 效果③的发动条件：以场上的「战华」怪兽为对象的效果发动时
function c82255872.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取该连锁发动时的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查对象中是否存在「战华」怪兽，且该发动可以被无效
	return g and g:IsExists(c82255872.tfilter,1,nil) and Duel.IsChainNegatable(ev)
end
-- 效果③的靶向与可行性检查
function c82255872.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果③的效果处理（使发动无效）
function c82255872.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
end
