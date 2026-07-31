--竜都アトランティス
local s,id,o=GetID()
-- 初始化卡片效果，注册场地卡通用的发动条件、等级调整效果、玩家目标效果和墓地起动效果
function s.initial_effect(c)
	-- 记录该卡记载着38391684和22702055这两张卡名
	aux.AddCodeList(c,38391684,22702055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场地卡生效时，使我方手牌和怪兽区的卡等级-1
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,LOCATION_HAND+LOCATION_MZONE)
	e2:SetCondition(s.lvcon)
	e2:SetValue(-1)
	c:RegisterEffect(e2)
	-- 场地卡生效时，使对方玩家受到该卡效果影响
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	-- 墓地起动效果：将此卡特殊召唤至场地区域
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.ftcon)
	e4:SetTarget(s.fttg)
	e4:SetOperation(s.ftop)
	c:RegisterEffect(e4)
end
-- 过滤器函数，用于检测场上是否有正面表示的38391684编号怪兽
function s.lvfilter(c)
	-- 返回值为真当且仅当c是正面表示并且记载着38391684编号
	return c:IsFaceup() and aux.IsCodeListed(c,38391684)
end
-- 判断条件函数，用于检测我方是否场上有至少1只正面表示的38391684编号怪兽
function s.lvcon(e)
	-- 返回值为真当且仅当我方场上有至少1只正面表示的38391684编号怪兽
	return Duel.IsExistingMatchingCard(s.lvfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤器函数，用于检测场上是否有正面表示的22702055编号怪兽
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsFaceup()
end
-- 判断条件函数，用于检测我方是否场上有至少1只正面表示的22702055编号怪兽或当前环境为22702055
function s.ftcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值为真当且仅当我方场上有至少1只正面表示的22702055编号怪兽或当前环境为22702055
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055,tp)
end
-- 目标函数，用于检测此卡是否可以特殊召唤至场地区域
function s.fttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsForbidden() and e:GetHandler():CheckUniqueOnField(tp) end
end
-- 操作函数，将此卡从墓地特殊召唤至场地区域并处理相关效果
function s.ftop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 获取我方灵摆区域的卡（位置5）
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 将fc送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理
			Duel.BreakEffect()
		end
		-- 将此卡移动到场地区域
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
