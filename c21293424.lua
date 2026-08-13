--空母軍貫－しらうお型特務艦
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡超量召唤成功的场合才能发动。那些作为超量召唤的素材的怪兽的以下效果适用。
-- ●「舍利军贯」：自己从卡组抽1张。
-- ●「银鱼军贯」：从卡组把1张「军贯」魔法·陷阱卡加入手卡。
-- ②：只要场地区域有表侧表示卡存在，从额外卡组特殊召唤的自己的「军贯」怪兽不会被对方的效果破坏，攻击力上升那原本守备力数值。
function c21293424.initial_effect(c)
	-- 记录这张卡上记载的卡名：24639891（舍利军贯）和78362751（银鱼军贯），用于相关卡名判定。
	aux.AddCodeList(c,24639891,78362751)
	-- 为这张卡添加超量召唤手续：4星怪兽×2叠放。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 那些作为超量召唤的素材的怪兽的以下效果适用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c21293424.valcheck)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡超量召唤成功的场合才能发动。那些作为超量召唤的素材的怪兽的以下效果适用。●「舍利军贯」：自己从卡组抽1张。●「银鱼军贯」：从卡组把1张「军贯」魔法·陷阱卡加入手卡。
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
	-- ②：只要场地区域有表侧表示卡存在，从额外卡组特殊召唤的自己的「军贯」怪兽不会被对方的效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c21293424.indescon)
	e2:SetTarget(c21293424.indestg)
	-- 设置不会被效果破坏的判定：仅对方发动的效果不会破坏此卡。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c21293424.atkval)
	c:RegisterEffect(e3)
end
-- 检查超量素材中是否包含舍利军贯（24639891）或银鱼军贯（78362751），分别置位标志1和2，存入LabelObject供①效果使用。
function c21293424.valcheck(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=0
	if c:GetMaterial():FilterCount(Card.IsCode,nil,24639891)>0 then flag=flag|1 end
	if c:GetMaterial():FilterCount(Card.IsCode,nil,78362751)>0 then flag=flag|2 end
	e:GetLabelObject():SetLabel(flag)
end
-- ①效果的发动条件：这张卡以超量召唤方式成功特殊召唤。
function c21293424.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 检索「军贯」魔法·陷阱卡的过滤器：卡名含「军贯」字段、属于魔法或陷阱卡、且可以加入手卡。
function c21293424.thfilter(c)
	return c:IsSetCard(0x166) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果发动时，读取素材标志，若chk==0则判定是否至少存在一个可适用的效果（抽卡或检索）作为发动条件。
function c21293424.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	-- 若有舍利军贯素材，则要求玩家可以抽1张卡才能发动。
	if chk==0 then return chk1 and Duel.IsPlayerCanDraw(tp,1)
		-- 若有银鱼军贯素材，则要求卡组中存在1张满足条件的「军贯」魔陷才能发动。
		or chk2 and Duel.IsExistingMatchingCard(c21293424.thfilter,tp,LOCATION_DECK,0,1,nil) end
	e:SetCategory(0)
	if chk1 then
		e:SetCategory(CATEGORY_DRAW)
		-- 设置抽卡操作信息：为tp玩家抽1张卡，供连锁中相关效果检测使用。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	if chk2 then
		e:SetCategory(e:GetCategory()|(CATEGORY_TOHAND+CATEGORY_SEARCH))
		-- 设置检索加入手卡操作信息：从卡组将1张卡加入手卡（数量1，来源卡组）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- ①效果处理：若素材有舍利军贯则玩家抽1张；若素材有银鱼军贯则玩家从卡组选1张「军贯」魔陷加入手卡并给对方确认。
function c21293424.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	if chk1 then
		-- 玩家tp以效果原因抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if chk2 then
		-- 显示“请选择要加入手牌的卡”的提示，要求玩家选择卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家tp从卡组选择1张满足thfilter的「军贯」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c21293424.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续加入手卡处理作为独立时点，避免与抽卡处理同时进行。
			Duel.BreakEffect()
			-- 将选中的卡以效果原因送入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示选中的那张加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的适用条件：场地区域存在表侧表示卡。
function c21293424.indescon(e)
	-- 检查双方场地区是否存在至少1张表侧表示的卡。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ②效果的适用对象：自己场上从额外卡组特殊召唤的、卡名含「军贯」的怪兽。
function c21293424.indestg(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x166)
end
-- 攻击力上升数值为这只怪兽的原本守备力数值。
function c21293424.atkval(e,c)
	return c:GetBaseDefense()
end
