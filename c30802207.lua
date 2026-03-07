--エクソシスター・カルペディベル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：双方不能把自己场上的「救祓少女」怪兽作为从墓地特殊召唤的怪兽的效果的对象。
-- ②：自己把「救祓少女」怪兽超量召唤的场合，宣言1个卡名才能发动。直到回合结束时，原本卡名和宣言的卡相同的卡的效果无效化。
-- ③：自己的「救祓少女」怪兽进行战斗的攻击宣言时，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c30802207.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 效果原文：双方不能把自己场上的「救祓少女」怪兽作为从墓地特殊召唤的怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c30802207.eftg)
	e1:SetValue(c30802207.efilter)
	c:RegisterEffect(e1)
	-- 效果原文：自己把「救祓少女」怪兽超量召唤的场合，宣言1个卡名才能发动。直到回合结束时，原本卡名和宣言的卡相同的卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30802207,0))  --"宣言卡名将其无效"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,30802207)
	e2:SetCondition(c30802207.bancon)
	e2:SetTarget(c30802207.bantg)
	e2:SetOperation(c30802207.banop)
	c:RegisterEffect(e2)
	-- 效果原文：自己的「救祓少女」怪兽进行战斗的攻击宣言时，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30802207,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,30802208)
	e3:SetCondition(c30802207.descon)
	e3:SetTarget(c30802207.destg)
	e3:SetOperation(c30802207.desop)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为「救祓少女」且表侧表示
function c30802207.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x172)
end
-- 判断效果是否为怪兽从墓地特殊召唤时发动的效果
function c30802207.efilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_GRAVE) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 判断目标怪兽是否为「救祓少女」超量怪兽且为我方召唤
function c30802207.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x172) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSummonPlayer(tp)
end
-- 判断是否有我方「救祓少女」超量怪兽特殊召唤成功
function c30802207.bancon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30802207.cfilter,1,nil,tp)
end
-- 选择并宣言一个卡名作为无效化目标
function c30802207.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择宣言卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家宣言一个卡牌编号
	local ac=Duel.AnnounceCard(tp)
	-- 将宣言的卡牌编号设置为连锁参数
	Duel.SetTargetParam(ac)
	-- 设置操作信息为宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 执行无效化效果，包括魔法陷阱和怪兽效果
function c30802207.banop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中宣言的卡牌编号
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	-- 创建一个使卡牌效果无效的永续效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(c30802207.distg1)
	e1:SetLabel(ac)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
	-- 创建一个在连锁处理时使效果无效的连续效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(c30802207.discon)
	e2:SetOperation(c30802207.disop)
	e2:SetLabel(ac)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上
	Duel.RegisterEffect(e2,tp)
	-- 创建一个使陷阱怪兽效果无效的永续效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c30802207.distg2)
	e3:SetLabel(ac)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上
	Duel.RegisterEffect(e3,tp)
end
-- 判断目标卡牌是否为指定编号的卡牌
function c30802207.distg1(e,c)
	local ac=e:GetLabel()
	if c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsOriginalCodeRule(ac)
	else
		return c:IsOriginalCodeRule(ac) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
	end
end
-- 判断目标怪兽是否为指定编号的卡牌
function c30802207.distg2(e,c)
	local ac=e:GetLabel()
	return c:IsOriginalCodeRule(ac)
end
-- 判断当前处理的连锁效果是否为指定编号的卡牌
function c30802207.discon(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	return re:GetHandler():IsOriginalCodeRule(ac)
end
-- 使指定编号的卡牌效果无效
function c30802207.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前处理的连锁效果无效
	Duel.NegateEffect(ev)
end
-- 判断是否为我方「救祓少女」怪兽攻击宣言
function c30802207.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的我方怪兽
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsSetCard(0x172) and tc:IsFaceup()
end
-- 判断目标卡牌是否为魔法或陷阱类型
function c30802207.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择并设置要破坏的魔法陷阱卡
function c30802207.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c30802207.desfilter(chkc) and chkc:IsControler(1-tp) end
	-- 判断是否有对方场上的魔法陷阱卡可选
	if chk==0 then return Duel.IsExistingTarget(c30802207.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的魔法陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c30802207.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c30802207.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
