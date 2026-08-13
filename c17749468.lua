--贖罪神女
-- 效果：
-- 「蓟花之妖魔」＋融合·同调怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上1只「圣蓟花」和对方场上1只表侧表示怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：场上的这张卡不会被效果破坏。
-- ②：每次对方把魔法·陷阱·怪兽的效果发动，对方场上的全部怪兽的攻击力下降500。
-- ③：只要这张卡在怪兽区域存在，对方不能把攻击力0的怪兽的效果发动。
local s,id,o=GetID()
-- 定义赎罪神女的初始效果注册函数，依次注册融合召唤手续、特殊召唤限制、特殊召唤规则、①效果抗性、②效果攻击力下降、③效果发动限制等全部效果。
function s.initial_effect(c)
	-- 注册卡名代码列表，将卡号85065943（「圣蓟花」）作为本卡效果涉及的相关卡名，便于后续检索识别。
	aux.AddCodeList(c,85065943)
	c:EnableReviveLimit()
	-- 为赎罪神女添加融合召唤手续：素材为1只卡号65033975的怪兽（「蓟花之妖魔」）和1只融合或同调怪兽。
	aux.AddFusionProcCodeFun(c,65033975,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO),1,true,true)
	-- “这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- “●把自己场上1只「圣蓟花」和对方场上1只表侧表示怪兽解放的场合可以从额外卡组特殊召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	-- “①：场上的这张卡不会被效果破坏。”
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- “②：每次对方把魔法·陷阱·怪兽的效果发动”
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- “对方场上的全部怪兽的攻击力下降500。”
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
	-- “③：只要这张卡在怪兽区域存在，对方不能把攻击力0的怪兽的效果发动。”
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
-- 判定特殊召唤条件：若这张卡在额外卡组，则只允许通过融合召唤方式特殊召唤；若在额外以外区域则不做限制。
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) then return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION end
	return true
end
-- 定义“圣蓟花”素材过滤条件：卡名必须为85065943（「圣蓟花」），控制权在自己场上，解放后额外怪兽区有空格可供本卡出场，且能作为本卡这次特殊召唤的融合素材。
function s.hspfilter1(c,tp,fc)
	return c:IsFusionCode(85065943)
		-- 补充当前条件：该素材必须在自己场上；且解放该素材后本卡有可用额外怪兽区域特殊召唤；且该素材可作为融合素材使用。
		and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0 and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 定义对方场上解放素材的过滤条件：对方场上的表侧表示怪兽，可以被解放作为本次特殊召唤的素材，并能作为融合素材。
function s.hspfilter2(c,tp,fc)
	return c:IsFaceup() and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 特殊召唤规则手续的发动条件：满足自己场上存在1张符合条件的「圣蓟花」素材，且对方场上有1只表侧表示怪兽可作为解放素材。
function s.hspcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在至少1张可解放的「圣蓟花」素材（满足s.hspfilter1的卡）。
	return Duel.CheckReleaseGroupEx(c:GetControler(),s.hspfilter1,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
		-- 检查对方场上是否存在至少1张表侧表示怪兽可满足解放素材条件（s.hspfilter2）。
		and Duel.IsExistingMatchingCard(s.hspfilter2,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤手续的目标选择：先从符合条件的自己场上「圣蓟花」中选择1张，再从对方场上的表侧表示怪兽中选择1张，将两张卡作为解放素材组保存，以备规则特殊召唤时解放。
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可解放的卡组，并筛选出所有符合条件的「圣蓟花」作为候选解放素材。
	local g1=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.hspfilter1,nil,tp,c)
	-- 向玩家显示“请选择要解放的卡”的提示消息，用于选择解放素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc1=g1:SelectUnselect(nil,tp,false,true,1,1)
	if tc1 then
		-- 获取对方场上表侧表示且满足解放素材条件的怪兽组，作为第二个解放素材的候选。
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
-- 在执行规则特殊召唤时，从效果标签中取出预先选定的解放素材组，将其作为这张卡的融合素材记录并解放，然后清理临时组。
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将选定的素材组解放，解放原因标记为特殊召唤和作为素材（REASON_SPSUMMON|REASON_MATERIAL）。
	Duel.Release(sg,REASON_SPSUMMON|REASON_MATERIAL)
	sg:DeleteGroup()
end
-- 当对方发动魔法·陷阱·怪兽效果时，给本卡注册一个标记（flag），用于记录本次连锁中有对方发动效果的事实，待连锁处理结束后判断是否执行降攻。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 降攻效果的处理条件：当前连锁是对方玩家发动的效果（rp==1-tp），且此前已通过s.regop注册过对方发动效果的标记。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:GetFlagEffect(id)~=0
end
-- 定义降攻对象过滤条件：选择对方场上的表侧表示怪兽，且该怪兽不受本卡效果免疫（可以被降攻）。
function s.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
-- 执行②效果：对对方场上全部符合条件的表侧表示怪兽各下降500攻击力，并展示卡片效果动画。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上全部满足降攻条件的表侧表示怪兽组，作为降攻施加对象。
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,e)
	if g:GetCount()>0 then
		-- 向场上玩家显示本卡（id）的效果发动/卡片动画，用于提示效果处理。
		Duel.Hint(HINT_CARD,0,id)
		-- 遍历降攻对象组g中的每只怪兽，逐一施加攻击力下降效果。
		for tc in aux.Next(g) do
			-- “对方场上的全部怪兽的攻击力下降500。”
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
-- ③效果的禁止发动条件判断：对方发动的效果必须是怪兽效果，且发动效果的那只怪兽的攻击力为0，此时禁止其发动。
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttack(0)
end
