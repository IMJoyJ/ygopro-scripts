--嫋々たる漣歌姫の壱世壊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的融合怪兽以及「珠泪哀歌族」怪兽的攻击力上升500。
-- ②：水族「珠泪哀歌族」怪兽被效果送去自己墓地的场合才能发动。从卡组把1只4星以下的水族怪兽送去墓地。这个效果把「珠泪哀歌族」怪兽以外的怪兽送去墓地的场合，这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
local s,id,o=GetID()
-- 初始化效果，注册场地魔法卡的发动和攻击力提升效果以及触发效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的融合怪兽以及「珠泪哀歌族」怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 水族「珠泪哀歌族」怪兽被效果送去自己墓地的场合才能发动。从卡组把1只4星以下的水族怪兽送去墓地。这个效果把「珠泪哀歌族」怪兽以外的怪兽送去墓地的场合，这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"从卡组把1只4星以下的水族怪兽送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为融合怪兽或珠泪哀歌族怪兽
function s.atktg(e,c)
	return c:IsType(TYPE_FUSION) or c:IsSetCard(0x181)
end
-- 过滤条件：被效果送入墓地且控制者为玩家、种族为水族、卡名包含珠泪哀歌族
function s.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsControler(tp) and c:IsRace(RACE_AQUA) and c:IsSetCard(0x181)
end
-- 判断是否有满足条件的水族珠泪哀歌族怪兽被送入墓地
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤条件：水族、4星以下、可送去墓地的怪兽
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_AQUA) and c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- 设置连锁操作信息，准备从卡组选择一只水族4星以下怪兽送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 发动效果，选择并送去墓地的卡，若不是珠泪哀歌族怪兽则禁止本回合发动该卡及同名卡的效果
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认选择的卡已成功送去墓地且位于墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and not tc:IsSetCard(0x181) then
		-- 创建并注册一个禁止发动效果的永续效果，防止本回合发动该卡及同名卡的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断效果是否为被禁止发动的卡
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
