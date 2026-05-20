--守護神エクゾード
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只名字带有「斯芬克斯」的怪兽解放的场合才能特殊召唤。只要这张卡在场上表侧表示存在，地属性怪兽反转召唤成功时，给与对方基本分1000分伤害。
function c55737443.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只名字带有「斯芬克斯」的怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c55737443.spcon)
	e2:SetTarget(c55737443.sptg)
	e2:SetOperation(c55737443.spop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，地属性怪兽反转召唤成功时，给与对方基本分1000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55737443,0))  --"LP伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c55737443.damcon)
	e3:SetTarget(c55737443.damtg)
	e3:SetOperation(c55737443.damop)
	c:RegisterEffect(e3)
end
-- 过滤满足特殊召唤解放条件的卡片（属于「斯芬克斯」系列，且解放后能让自身特殊召唤到怪兽区域）
function c55737443.spfilter(c,tp)
	return c:IsSetCard(0x5c)
		-- 检查将该卡解放后是否有可用的怪兽区域，且该卡必须由自己控制或者是场上表侧表示的卡
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件检查函数
function c55737443.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1只满足特殊召唤解放条件的怪兽
	return Duel.CheckReleaseGroupEx(tp,c55737443.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的选择解放怪兽的目标函数
function c55737443.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放且满足「斯芬克斯」过滤条件的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c55737443.spfilter,nil,tp)
	-- 给玩家发送“请选择要解放的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行解放操作函数
function c55737443.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽以进行特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 伤害效果的发动条件检查（非自身且是地属性怪兽反转召唤成功时）
function c55737443.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc~=e:GetHandler() and tc:IsAttribute(ATTRIBUTE_EARTH)
end
-- 伤害效果的靶向与操作信息注册函数
function c55737443.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的对象参数为1000（伤害数值）
	Duel.SetTargetParam(1000)
	-- 注册连锁的操作信息，表示该效果会给与对方1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的执行函数
function c55737443.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成设定的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
