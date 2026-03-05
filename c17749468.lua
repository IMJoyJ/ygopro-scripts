--贖罪神女
-- 效果：
-- 「蓟花之妖魔」＋融合·同调怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上1只「圣蓟花」和对方场上1只表侧表示怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：场上的这张卡不会被效果破坏。
-- ②：每次对方把魔法·陷阱·怪兽的效果发动，对方场上的全部怪兽的攻击力下降500。
-- ③：只要这张卡在怪兽区域存在，对方不能把攻击力0的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册额外卡组特殊召唤条件、融合召唤手续、永续效果等
function s.initial_effect(c)
	-- 记录该卡拥有「圣蓟花」的卡名
	aux.AddCodeList(c,85065943)
	c:EnableReviveLimit()
	-- 设置融合召唤所需素材为1只「蓟花之妖魔」或融合·同调怪兽
	aux.AddFusionProcCodeFun(c,65033975,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO),1,true,true)
	-- ①：场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ●把自己场上1只「圣蓟花」和对方场上1只表侧表示怪兽解放的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	-- ①：场上的这张卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：每次对方把魔法·陷阱·怪兽的效果发动，对方场上的全部怪兽的攻击力下降500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- ②：每次对方把魔法·陷阱·怪兽的效果发动，对方场上的全部怪兽的攻击力下降500。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
	-- ③：只要这张卡在怪兽区域存在，对方不能把攻击力0的怪兽的效果发动。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,1)
	e6:SetValue(s.aclimit)
	c:RegisterEffect(e6)
end
s.material_type=TYPE_SYNCHRO
-- 限制该卡只能通过融合召唤或指定方法从额外卡组特殊召唤
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) then return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION end
	return true
end
-- 筛选满足条件的「圣蓟花」作为融合素材
function s.hspfilter1(c,tp,fc)
	return c:IsFusionCode(85065943)
		-- 满足条件的「圣蓟花」必须在自己场上且能被特殊召唤
		and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0 and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 筛选满足条件的对方表侧表示怪兽作为解放对象
function s.hspfilter2(c,tp,fc)
	return c:IsFaceup() and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 判断是否满足特殊召唤条件：自己场上存在「圣蓟花」且对方场上存在表侧表示怪兽
function s.hspcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在满足条件的「圣蓟花」
	return Duel.CheckReleaseGroupEx(c:GetControler(),s.hspfilter1,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
		-- 检查对方场上是否存在表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.hspfilter2,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 设置特殊召唤时的选择处理流程
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的「圣蓟花」卡片组
	local g1=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.hspfilter1,nil,tp,c)
	-- 提示玩家选择要解放的「圣蓟花」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc1=g1:SelectUnselect(nil,tp,false,true,1,1)
	if tc1 then
		-- 获取满足条件的对方表侧表示怪兽卡片组
		local g2=Duel.GetMatchingGroup(s.hspfilter2,tp,0,LOCATION_MZONE,tc1,tp,c)
		local tc2=g2:SelectUnselect(nil,tp,false,true,1,1)
		if tc2 then
			local mg=Group.CreateGroup()
			mg:AddCard(tc1)
			mg:AddCard(tc2)
			mg:KeepAlive()
			e:SetLabelObject(mg)
			return true
		end
		return false
	else return false end
end
-- 执行特殊召唤时的解放操作
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将指定卡片组解放
	Duel.Release(sg,REASON_SPSUMMON|REASON_MATERIAL)
	sg:DeleteGroup()
end
-- 记录连锁发动标志，用于触发效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 判断是否为对方发动效果且该卡已记录连锁标志
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:GetFlagEffect(id)~=0
end
-- 筛选满足条件的对方怪兽
function s.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
-- 处理对方发动效果时，使对方场上所有怪兽攻击力下降500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,e)
	if g:GetCount()>0 then
		-- 提示发动效果动画
		Duel.Hint(HINT_CARD,0,id)
		-- 遍历所有满足条件的怪兽
		for tc in aux.Next(g) do
			-- 使目标怪兽攻击力下降500
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 限制对方不能发动攻击力为0的怪兽效果
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttack(0)
end
