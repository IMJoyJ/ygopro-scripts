--アサルト・リオン
local s,id,o=GetID()
-- 初始化卡片效果：注册1只祭品的上级召唤手续、战斗伤害翻倍效果以及墓地回收并通常召唤效果
function s.initial_effect(c)
	-- 注册此卡已在墓地的标记检测效果
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这张卡可以把1只兽战士族怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡和怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(s.damcon)
	-- 将给与对方的战斗伤害变为2倍
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	-- 这个卡名的效果1回合只能使用1次。这张卡在墓地存在，自己场上有兽战士族怪兽召唤·特殊召唤的场合才能发动。这张卡加入手卡。那之后，可以把1只怪兽通常召唤。这个效果通常召唤的怪兽攻击力上升500，从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetLabelObject(e0)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤场上可作为解放素材的兽战士族怪兽
function s.otfilter(c,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and (c:IsControler(tp) or c:IsFaceup())
end
-- 1只祭品上级召唤的发动条件与合法性检查
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上可作为解放素材的兽战士族怪兽
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查怪兽等级是否为7星以上且场上存在可解放的兽战士族怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤操作：选择场上1只兽战士族怪兽解放
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上可作为解放素材的兽战士族怪兽
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只兽战士族怪兽作为解放素材
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为上级召唤的素材
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 战斗伤害翻倍效果的适用条件：自身与怪兽进行战斗
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 过滤自己场上召唤·特殊召唤成功的表侧表示兽战士族怪兽
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR) and c:IsControler(tp) and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果发动条件：自己场上有兽战士族怪兽召唤·特殊召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- 效果发动目标检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将自身从墓地加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：自身加入手卡，可再进行1只怪兽的通常召唤（攻击力上升500且离场除外）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍在墓地且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡
		Duel.ConfirmCards(1-tp,c)
		-- 检查自身是否可以进行通常召唤并询问玩家是否进行召唤
		if c:IsSummonable(true,nil,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断效果处理
			Duel.BreakEffect()
			-- 对自身进行通常召唤（至少使用1只祭品）
			Duel.Summon(tp,c,true,nil,1)
			-- 这个效果通常召唤的怪兽攻击力上升500
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE-RESET_TOFIELD)
			e1:SetValue(500)
			c:RegisterEffect(e1)
			-- 从场上离开的场合除外。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e2:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e2,true)
		end
	end
end
