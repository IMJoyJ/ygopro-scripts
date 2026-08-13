--嫋々たる漣歌姫の壱世壊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的融合怪兽以及「珠泪哀歌族」怪兽的攻击力上升500。
-- ②：水族「珠泪哀歌族」怪兽被效果送去自己墓地的场合才能发动。从卡组把1只4星以下的水族怪兽送去墓地。这个效果把「珠泪哀歌族」怪兽以外的怪兽送去墓地的场合，这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
local s,id,o=GetID()
-- 注册该卡片的三个效果：e1作为场地魔法可发动的许可；e2实现①效果，使我方场上的融合怪兽和「珠泪哀歌族」怪兽攻击力上升500；e3实现②效果，响应水族「珠泪哀歌族」怪兽被效果送去自己墓地时从卡组送墓水族怪兽并附加同名卡效果发动限制。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的融合怪兽以及「珠泪哀歌族」怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：水族「珠泪哀歌族」怪兽被效果送去自己墓地的场合才能发动。从卡组把1只4星以下的水族怪兽送去墓地。这个效果把「珠泪哀歌族」怪兽以外的怪兽送去墓地的场合，这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
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
-- ①效果的适用对象筛选：怪兽必须是融合怪兽或「珠泪哀歌族」怪兽。
function s.atktg(e,c)
	return c:IsType(TYPE_FUSION) or c:IsSetCard(0x181)
end
-- ②效果触发条件的单卡筛选：该怪兽是因效果被送去自己墓地的水族「珠泪哀歌族」怪兽（即被效果送入自己墓地且控制者为己方的珠泪哀歌族水族怪兽）。
function s.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsControler(tp) and c:IsRace(RACE_AQUA) and c:IsSetCard(0x181)
end
-- ②效果的发动条件判定：本次被送去墓地的卡中至少存在1只满足s.cfilter的水族「珠泪哀歌族」怪兽。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 从卡组选卡的筛选条件：4星以下的水族怪兽，且可以被送去墓地。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_AQUA) and c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- ②效果的发动时处理：检查卡组是否存在符合条件的4星以下水族怪兽，并设置从卡组将1张卡送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动的合法性检查：卡组中是否存在至少1只可被送去墓地的4星以下水族怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：将1张卡从持有者的卡组送去墓地（用于后续连锁和效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只4星以下水族怪兽送去墓地；若该怪兽不是「珠泪哀歌族」怪兽，则为己方附加本回合不能发动该卡及同名卡效果的限制。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示操作者选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组选择1只满足s.tgfilter的水族怪兽（不取对象，仅在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断所选怪兽是否确实被效果送入墓地且仍存在于墓地，并且其不是「珠泪哀歌族」怪兽，以决定是否施加本回合同名卡效果发动限制。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and not tc:IsSetCard(0x181) then
		-- 这个效果把「珠泪哀歌族」怪兽以外的怪兽送去墓地的场合，这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果e1注册给己方玩家，使其在本回合内受到‘不能发动被送墓之卡及同名卡的效果’的限制。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃效果的判定：若某个玩家尝试发动的效果所属卡片的卡号与e1标签记录的被送墓卡的卡号相同，则禁止该效果发动。
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
