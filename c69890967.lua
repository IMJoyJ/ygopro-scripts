--幻魔皇ラビエル
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只恶魔族怪兽解放的场合才能特殊召唤。
-- ①：1回合1次，把这张卡以外的自己场上1只怪兽解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
-- ②：对方对怪兽的召唤成功的场合发动。在自己场上把1只「幻魔衍生物」（恶魔族·暗·1星·攻/守1000）特殊召唤。这衍生物不能攻击宣言。
function c69890967.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使这张卡不能被通常的特殊召唤方式召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上3只恶魔族怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c69890967.spcon)
	e2:SetTarget(c69890967.sptg)
	e2:SetOperation(c69890967.spop)
	c:RegisterEffect(e2)
	-- ②：对方对怪兽的召唤成功的场合发动。在自己场上把1只「幻魔衍生物」（恶魔族·暗·1星·攻/守1000）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69890967,0))  --"特殊召唤Token"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c69890967.tkcon)
	e3:SetTarget(c69890967.tktg)
	e3:SetOperation(c69890967.tkop)
	c:RegisterEffect(e3)
	-- ①：1回合1次，把这张卡以外的自己场上1只怪兽解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69890967,1))  --"攻击上升"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c69890967.atcost)
	e4:SetOperation(c69890967.atop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上的恶魔族怪兽（若在对方场上则必须表侧表示）
function c69890967.rfilter(c,tp)
	return c:IsRace(RACE_FIEND) and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件：检查自己场上是否有3只可解放的恶魔族怪兽，且解放后有足够的怪兽区域
function c69890967.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上可用于特殊召唤解放的恶魔族怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c69890967.rfilter,nil,tp)
	-- 检查是否能选出3只怪兽，在解放它们后主怪兽区仍有空位来特殊召唤此卡
	return rg:CheckSubGroup(aux.mzctcheckrel,3,3,tp,REASON_SPSUMMON)
end
-- 特殊召唤规则的选卡阶段：让玩家选择3只用于解放的恶魔族怪兽，并保存选择的卡片组
function c69890967.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可用于特殊召唤解放的恶魔族怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c69890967.rfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择3只在解放后能腾出足够怪兽区域的恶魔族怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,3,3,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行阶段：解放选定的怪兽并清理临时卡片组
function c69890967.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽以进行特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 衍生物产生效果的发动条件：对方召唤怪兽成功时
function c69890967.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 衍生物产生效果的靶向阶段：声明将特殊召唤衍生物的操作信息
function c69890967.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将产生1只衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置将特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 衍生物产生效果的执行阶段：在自己场上特殊召唤1只「幻魔衍生物」，并限制其不能攻击宣言
function c69890967.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若没有空余怪兽区域，或玩家不能特殊召唤该衍生物，则不处理效果
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,69890968,0,TYPES_TOKEN_MONSTER,1000,1000,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建「幻魔衍生物」的卡片数据
	local token=Duel.CreateToken(tp,69890968)
	-- 将衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1,true)
end
-- 攻击力上升效果的代价阶段：解放这张卡以外的自己场上1只怪兽，并记录其原本攻击力
function c69890967.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	-- 选择自己场上除这张卡以外的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 解放选定的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 攻击力上升效果的执行阶段：使这张卡的攻击力上升解放怪兽的原本攻击力数值，直到回合结束
function c69890967.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
