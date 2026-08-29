--レプティレス・エキドゥーナ
-- 效果：
-- 包含爬虫类族怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
-- ②：自己主要阶段才能发动。把最多有对方场上的攻击力0的怪兽数量的爬虫类族怪兽从卡组加入手卡（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不是爬虫类族怪兽不能从额外卡组特殊召唤。
function c8602351.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：包含爬虫类族怪兽的怪兽2只
	aux.AddLinkProcedure(c,nil,2,2,c8602351.lcheck)
	-- ①：这张卡连接召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8602351,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,8602351)
	e1:SetCondition(c8602351.atkcon)
	e1:SetTarget(c8602351.atktg)
	e1:SetOperation(c8602351.atkop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。把最多有对方场上的攻击力0的怪兽数量的爬虫类族怪兽从卡组加入手卡（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不是爬虫类族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8602351,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,8602352)
	e2:SetTarget(c8602351.thtg)
	e2:SetOperation(c8602351.thop)
	c:RegisterEffect(e2)
end
-- 连接素材检查（至少包含1只爬虫类族怪兽）
function c8602351.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_REPTILE)
end
-- 判断自身是否连接召唤成功
function c8602351.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 攻击力变为0效果的目标确认与对象选择
function c8602351.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 重验对象是否为对方场上表侧表示且攻击力大于0的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 检查对方场上是否存在表侧表示且攻击力大于0的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示且攻击力大于0的怪兽作为对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 执行将目标怪兽攻击力变成0的操作
function c8602351.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤场上表侧表示且攻击力为0的怪兽
function c8602351.cfilter(c)
	return c:IsFaceup() and c:IsAttack(0)
end
-- 过滤卡组中可加入手卡的爬虫类族怪兽
function c8602351.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 检索效果的目标确认与操作信息设置
function c8602351.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上表侧表示且攻击力为0的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c8602351.cfilter,tp,0,LOCATION_MZONE,nil)
	-- 获取卡组中可加入手卡的爬虫类族怪兽组
	local g=Duel.GetMatchingGroup(c8602351.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return ct>0 and g:GetCount()>0 end
	-- 设置从卡组将怪兽加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索爬虫类族怪兽及附加额外卡组特殊召唤限制的操作
function c8602351.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上表侧表示且攻击力为0的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c8602351.cfilter,tp,0,LOCATION_MZONE,nil)
	-- 获取卡组中可加入手卡的爬虫类族怪兽组
	local g=Duel.GetMatchingGroup(c8602351.thfilter,tp,LOCATION_DECK,0,nil)
	if ct>0 and g:GetCount()>0 then
		-- 提示选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择最多不超过对方场上攻击力0怪兽数量的同名卡最多1张的爬虫类族怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		if sg then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是爬虫类族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c8602351.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册直到回合结束不能从额外卡组特殊召唤非爬虫类族怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能从额外卡组特殊召唤非爬虫类族怪兽
function c8602351.splimit(e,c)
	return not c:IsRace(RACE_REPTILE) and c:IsLocation(LOCATION_EXTRA)
end
