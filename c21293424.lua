--空母軍貫－しらうお型特務艦
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡超量召唤成功的场合才能发动。那些作为超量召唤的素材的怪兽的以下效果适用。
-- ●「舍利军贯」：自己从卡组抽1张。
-- ●「银鱼军贯」：从卡组把1张「军贯」魔法·陷阱卡加入手卡。
-- ②：只要场地区域有表侧表示卡存在，从额外卡组特殊召唤的自己的「军贯」怪兽不会被对方的效果破坏，攻击力上升那原本守备力数值。
function c21293424.initial_effect(c)
	-- 注册该卡牌效果中涉及的其他卡名代码，用于识别超量素材中的「舍利军贯」和「银鱼军贯」
	aux.AddCodeList(c,24639891,78362751)
	-- 设置该卡牌的超量召唤条件，需要4星怪兽2只作为素材进行超量召唤
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 设置超量召唤成功时的处理效果，用于检测超量素材中是否包含特定卡名
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c21293424.valcheck)
	c:RegisterEffect(e0)
	-- 设置超量召唤成功时发动的效果，根据超量素材中是否包含特定卡名来决定效果内容
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21293424,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,21293424)
	e1:SetCondition(c21293424.effcon)
	e1:SetTarget(c21293424.efftg)
	e1:SetOperation(c21293424.effop)
	c:RegisterEffect(e1)
	e0:SetLabelObject(e1)
	-- 设置场地区域存在表侧表示卡时，从额外卡组特殊召唤的自己的「军贯」怪兽不会被对方效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c21293424.indescon)
	e2:SetTarget(c21293424.indestg)
	-- 设置该效果的过滤函数，用于判断是否不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c21293424.atkval)
	c:RegisterEffect(e3)
end
-- 检测超量召唤时所使用的素材是否包含「舍利军贯」或「银鱼军贯」，并将结果标记在效果标签中
function c21293424.valcheck(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=0
	if c:GetMaterial():FilterCount(Card.IsCode,nil,24639891)>0 then flag=flag|1 end
	if c:GetMaterial():FilterCount(Card.IsCode,nil,78362751)>0 then flag=flag|2 end
	e:GetLabelObject():SetLabel(flag)
end
-- 判断该卡是否为超量召唤成功，用于触发效果
function c21293424.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 定义检索卡组中「军贯」魔法·陷阱卡的过滤条件
function c21293424.thfilter(c)
	return c:IsSetCard(0x166) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果的发动条件，判断是否可以发动抽卡或检索效果
function c21293424.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	-- 判断是否可以发动抽卡效果，即是否包含「舍利军贯」素材
	if chk==0 then return chk1 and Duel.IsPlayerCanDraw(tp,1)
		-- 判断是否可以发动检索效果，即是否包含「银鱼军贯」素材
		or chk2 and Duel.IsExistingMatchingCard(c21293424.thfilter,tp,LOCATION_DECK,0,1,nil) end
	e:SetCategory(0)
	if chk1 then
		e:SetCategory(CATEGORY_DRAW)
		-- 设置抽卡效果的操作信息，指定抽卡数量和对象
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	if chk2 then
		e:SetCategory(e:GetCategory()|(CATEGORY_TOHAND+CATEGORY_SEARCH))
		-- 设置检索效果的操作信息，指定检索卡的数量和位置
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 执行效果的处理操作，根据标记决定是否抽卡或检索
function c21293424.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	if chk1 then
		-- 执行抽卡操作，从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if chk2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「军贯」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c21293424.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 将选中的卡送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看所选的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断场地区域是否存在表侧表示的魔法卡
function c21293424.indescon(e)
	-- 检查玩家场地区域是否存在至少1张表侧表示的魔法卡
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置该效果的目标过滤条件，判断是否为从额外卡组特殊召唤的「军贯」怪兽
function c21293424.indestg(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x166)
end
-- 设置攻击力增加的数值，增加量为怪兽的原本守备力数值
function c21293424.atkval(e,c)
	return c:GetBaseDefense()
end
