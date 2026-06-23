--超重輝将ヒス－E
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「超重武者」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：1回合1次，以自己场上1只「超重武者」怪兽为对象才能发动。那只怪兽的等级上升1星。
-- 【怪兽效果】
-- 这张卡在规则上也当作「超重武者」卡使用。这张卡可以把1只「超重武者」怪兽解放作上级召唤。
-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
function c42880485.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- 自己不是「超重武者」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c42880485.splimcon)
	e2:SetTarget(c42880485.splimit)
	c:RegisterEffect(e2)
	-- 1回合1次，以自己场上1只「超重武者」怪兽为对象才能发动。那只怪兽的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c42880485.lvtg)
	e3:SetOperation(c42880485.lvop)
	c:RegisterEffect(e3)
	-- 这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetTarget(c42880485.postg)
	e4:SetOperation(c42880485.posop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	-- 这张卡可以把1只「超重武者」怪兽解放作上级召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(42880485,0))  --"把1只「超重武者」怪兽解放作上级召唤"
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SUMMON_PROC)
	e6:SetCondition(c42880485.otcon)
	e6:SetOperation(c42880485.otop)
	e6:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e7)
	-- 这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_DEFENSE_ATTACK)
	e8:SetValue(1)
	c:RegisterEffect(e8)
end
-- 判断灵摆召唤是否被禁止
function c42880485.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
-- 限制非「超重武者」怪兽进行灵摆召唤
function c42880485.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x9a) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤满足条件的「超重武者」怪兽
function c42880485.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a) and c:GetLevel()>0
end
-- 选择目标「超重武者」怪兽
function c42880485.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42880485.filter(chkc) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c42880485.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标「超重武者」怪兽
	Duel.SelectTarget(tp,c42880485.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 提升目标怪兽等级
function c42880485.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为目标怪兽增加1星等级
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 设置表示形式变更的操作信息
function c42880485.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示形式变更
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 执行表示形式变更操作
function c42880485.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 过滤可用于上级召唤的「超重武者」怪兽
function c42880485.otfilter(c,tp)
	return c:IsSetCard(0x9a) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤条件
function c42880485.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取可用于上级召唤的怪兽组
	local mg=Duel.GetMatchingGroup(c42880485.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否满足上级召唤的等级和祭品条件
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤的解放操作
function c42880485.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取可用于上级召唤的怪兽组
	local mg=Duel.GetMatchingGroup(c42880485.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择用于上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放祭品怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
