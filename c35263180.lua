--オオヤツ・ツマムヒメ
-- 效果：
-- ①：1回合1次，场上的这张卡成为攻击·效果的对象时才能发动。在自己场上把1只「点心衍生物」（植物族·光·1星·攻/守800）特殊召唤。
-- ②：1回合1次，对方把怪兽特殊召唤之际，把自己场上1只通常怪兽解放才能发动。那次特殊召唤无效，那些怪兽破坏。
local s,id,o=GetID()
-- 创建并注册两个诱发即时效果，分别对应①②效果
function s.initial_effect(c)
	-- ①：1回合1次，场上的这张卡成为攻击·效果的对象时才能发动。在自己场上把1只「点心衍生物」（植物族·光·1星·攻/守800）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.tkecon)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(s.tkbcon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方把怪兽特殊召唤之际，把自己场上1只通常怪兽解放才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判断：连锁效果是否具有取对象属性且对象包含此卡
function s.tkecon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(e:GetHandler())
end
-- 效果②的发动条件判断：此卡被选为攻击对象
function s.tkbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡是否为攻击对象
	return Duel.GetAttackTarget()==e:GetHandler()
end
-- 效果①的发动时的处理判断：判断是否满足特殊召唤token的条件
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤token
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,1,RACE_PLANT,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：将要特殊召唤token
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤token
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的发动处理：判断是否满足特殊召唤token的条件
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 判断是否可以特殊召唤token
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,1,RACE_PLANT,ATTRIBUTE_LIGHT) then return end
	-- 创建token
	local tk=Duel.CreateToken(tp,id+o)
	-- 将token特殊召唤到场上
	Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件判断：当前无连锁且为对方发动特殊召唤
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前无连锁且为对方发动特殊召唤
	return Duel.GetCurrentChain()==0 and ep==1-tp
end
-- 效果②的发动费用：选择并解放一只通常怪兽
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可解放的通常怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_NORMAL) end
	-- 选择一只通常怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_NORMAL)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 效果②的发动处理：设置操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要无效召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	-- 设置操作信息：将要破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
-- 效果②的发动处理：执行无效召唤和破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方的特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏对方特殊召唤的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
