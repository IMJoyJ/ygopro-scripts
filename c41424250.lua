--カオスエンド・ルーラー －開闢と終焉の支配者－
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把战士族·光属性和恶魔族·暗属性的怪兽各1只除外的场合才能特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的特殊召唤不会被无效化。
-- ②：在这张卡的特殊召唤成功时双方不能把卡的效果发动。
-- ③：这张卡是已用上记的方法特殊召唤的场合，支付1000基本分才能发动。对方的场上·墓地的卡全部除外。那之后，给与对方这个效果除外的数量×500伤害。
local s,id,o=GetID()
-- 注册卡片效果的函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡的特殊召唤不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	-- 从自己墓地把战士族·光属性和恶魔族·暗属性的怪兽各1只除外的场合才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetValue(SUMMON_VALUE_SELF)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ②：在这张卡的特殊召唤成功时双方不能把卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.sumsuc)
	c:RegisterEffect(e4)
	-- ③：这张卡是已用上记的方法特殊召唤的场合，支付1000基本分才能发动。对方的场上·墓地的卡全部除外。那之后，给与对方这个效果除外的数量×500伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"除外"
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCondition(s.rmcon)
	e5:SetCost(s.rmcost)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
-- 过滤函数：自己墓地中可用于特殊召唤代价除外的光/暗属性怪兽
function s.spcostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤函数：判定用于特殊召唤除外的怪兽是否属于战士族·光属性或者恶魔族·暗属性
function s.spfilter(c,res)
	if res then
		return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
	else
		return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)
	end
end
-- 特殊召唤规则的发动条件判定函数
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己场上是否有空余的怪兽区域
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中所有符合除外代价条件的怪兽组
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	-- 检查墓地怪兽组中是否包含可作为召唤代价除外的一只战士族·光属性和一只恶魔族·暗属性怪兽
	return g:CheckSubGroup(aux.gfcheck,2,2,s.spfilter,true,false)
end
-- 特殊召唤规则的代价选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有符合除外代价条件的怪兽组
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	-- 给玩家提示：选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的一只战士族·光属性和一只恶魔族·暗属性怪兽
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,s.spfilter,true,false)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的实际操作函数
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选择的墓地怪兽正面除外以特殊召唤这张卡
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 特殊召唤成功时的效果处理辅助函数
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 限制双方直到连锁结束前都不能发动卡的效果
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
-- 除外与伤害效果的发动条件判定函数
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 除外与伤害效果的发动代价函数
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能够支付1000生命值作为发动代价
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000生命值作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 除外与伤害效果的发动准备与合法性检测函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测对方场上或墓地是否存在可以被除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取对方场上与墓地中所有可以被除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置连锁操作信息：包含除外对方场上·墓地卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：包含给与对方伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 除外与伤害效果的效果处理函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方墓地中的所有卡
	local ckg=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	-- 检测并判定是否由于王家长眠之谷的效果导致该效果无效
	if aux.NecroValleyNegateCheck(ckg) then return end
	-- 获取对方场上与墓地中当前所有可被除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 将满足条件的对方场上·墓地的卡全部除外并判定是否成功
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 计算此效果中实际被除外并移动到除外区的卡片数量
		local dam=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED):GetCount()
		if dam>0 then
			-- 给与对方这个效果除外的数量×500伤害
			Duel.Damage(1-tp,dam*500,REASON_EFFECT)
		end
	end
end
