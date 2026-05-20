--E-HERO インフェルノ・ウィング－ヘルバック・ファイア
-- 效果：
-- 「元素英雄 羽翼侠」或「元素英雄 爆热女郎」＋「英雄」怪兽
-- 这张卡用「暗黑融合」的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。除融合怪兽外的1张「暗黑融合」或者有那个卡名记述的卡从自己的卡组·墓地加入手卡。
-- ②：自己的「英雄」怪兽战斗破坏对方怪兽的场合发动。给与对方2100伤害。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果（特殊召唤限制、特殊召唤成功时检索/回收、英雄怪兽战破对方怪兽时给予伤害）
function s.initial_effect(c)
	-- 将「暗黑融合」、「元素英雄 爆热女郎」、「元素英雄 羽翼侠」注册为此卡效果文本中记载的卡片
	aux.AddCodeList(c,94820406,21844576,58932615)
	-- 将「元素英雄 爆热女郎」和「元素英雄 羽翼侠」注册为此卡的融合素材
	aux.AddMaterialCodeList(c,21844576,58932615)
	-- 设置融合召唤手续：以「元素英雄 羽翼侠」或「元素英雄 爆热女郎」加上1只「英雄」怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,{21844576,58932615},aux.FilterBoolFunction(Card.IsFusionSetCard,0x08),1,true,true)
	c:EnableReviveLimit()
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使其只能通过「暗黑融合」或相关效果特殊召唤
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合才能发动。除融合怪兽外的1张「暗黑融合」或者有那个卡名记述的卡从自己的卡组·墓地加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己的「英雄」怪兽战斗破坏对方怪兽的场合发动。给与对方2100伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"给与伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.dark_calling=true
s.material_setcode=0x8
-- 过滤函数：检索/回收卡组或墓地中除融合怪兽以外的「暗黑融合」或记有该卡名的卡
function s.thfilter(c)
	-- 检查卡片是否为「暗黑融合」或记有「暗黑融合」卡名，且能加入手牌
	return (c:IsCode(94820406) or aux.IsCodeListed(c,94820406)) and c:IsAbleToHand()
		and not c:IsType(TYPE_FUSION)
end
-- ①效果的发动准备，检查卡组或墓地中是否存在可检索/回收的卡，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，表示此效果的处理包含从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的执行函数，从卡组或墓地选择1张满足条件的卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地中选择1张满足过滤条件且不受「王家长眠之谷」影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检查被战斗破坏的怪兽是否原本由对方控制，且是被己方场上的「英雄」怪兽战斗破坏
function s.damfilter(c,tp)
	if not c:IsPreviousControler(1-tp) then return false end
	local bc=c:GetReasonCard()
	if not bc then return false end
	if bc:IsRelateToBattle() then
		return bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE) and bc:IsControler(tp) and bc:IsType(TYPE_MONSTER) and bc:IsSetCard(0x8)
	else
		return bc:GetPreviousPosition()&POS_FACEUP>0 and bc:GetPreviousLocation()&LOCATION_MZONE==LOCATION_MZONE and bc:IsPreviousControler(tp)
			and bc:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER and bc:IsPreviousSetCard(0x8)
	end
end
-- ②效果的发动条件，检查被战斗破坏的怪兽中是否存在满足条件的卡
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damfilter,1,nil,tp)
end
-- ②效果的发动准备，设置伤害目标玩家为对方，伤害数值为2100，并设置操作信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果处理对象玩家设定为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果处理参数设定为2100
	Duel.SetTargetParam(2100)
	-- 设置操作信息，表示此效果的处理包含给予对方玩家2100点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2100)
end
-- ②效果的执行函数，获取设定的目标玩家和伤害数值，并给予对方伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给予目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
