--CNo.79 BK 将星のカエサル
-- 效果：
-- 5星怪兽×3
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：1回合1次，对方把怪兽特殊召唤之际才能发动。这张卡2个超量素材取除，那个无效并破坏。
-- ③：这张卡有「No.79 燃烧拳击手 新星之帝环拳士」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，自己的「燃烧拳击手」怪兽和对方怪兽进行战斗的攻击宣言时才能发动。从手卡·卡组把1只「燃烧拳击手」怪兽送去墓地，那只对方怪兽作为这张卡的超量素材。
function c10300821.initial_effect(c)
	-- 添加超量召唤手续：5星怪兽×3
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c10300821.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方把怪兽特殊召唤之际才能发动。这张卡2个超量素材取除，那个无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10300821,0))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c10300821.discon)
	e2:SetTarget(c10300821.distg)
	e2:SetOperation(c10300821.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡有「No.79 燃烧拳击手 新星之帝环拳士」在作为超量素材的场合，得到以下效果。●1回合1次，自己的「燃烧拳击手」怪兽和对方怪兽进行战斗 of 攻击宣言时才能发动。从手卡·卡组把1只「燃烧拳击手」怪兽送去墓地，那只对方怪兽作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10300821,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c10300821.tgcon)
	e3:SetTarget(c10300821.tgtg)
	e3:SetOperation(c10300821.tgop)
	c:RegisterEffect(e3)
end
-- 设定此卡的No.号为79
aux.xyz_number[10300821]=79
-- 攻击力上升数值的计算函数：超量素材数量×200
function c10300821.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- ②之效果的发动条件判定
function c10300821.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为对方进行不入连锁的特殊召唤之际
	return ep==1-tp and Duel.GetCurrentChain()==0
end
-- ②之效果的发动准备：进行超量素材消耗判定并注册操作信息
function c10300821.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_EFFECT) end
	-- 注册无效特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 注册破坏被无效召唤的怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- ②之效果的效果处理：取除超量素材并将特殊召唤无效并破坏
function c10300821.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:RemoveOverlayCard(tp,2,2,REASON_EFFECT)>0 then
		-- 使正在特殊召唤的怪兽的特殊召唤无效
		Duel.NegateSummon(eg)
		-- 将特殊召唤无效的怪兽破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ③得到之效果的发动条件判定：有「No.79 燃烧拳击手 新星之帝环拳士」在超量素材中，且我方「燃烧拳击手」怪兽与对方怪兽战斗的攻击宣言时
function c10300821.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,71921856) then return false end
	-- 获取当前处于战斗中的我方怪兽与对方怪兽
	local a,d=Duel.GetBattleMonster(tp)
	if a and d and a:IsFaceup() and a:IsSetCard(0x1084) then
		e:SetLabelObject(d)
		return true
	else return false end
end
-- 过滤手卡或卡组中符合送墓条件的「燃烧拳击手」怪兽
function c10300821.tgfilter(c)
	return c:IsSetCard(0x1084) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ③得到之效果的发动准备：进行卡片重叠与送墓判定的处理
function c10300821.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc:IsCanOverlay()
		-- 判定手卡或卡组是否存在符合条件的「燃烧拳击手」怪兽
		and Duel.IsExistingMatchingCard(c10300821.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 将正与我方怪兽进行战斗的对方怪兽设定为效果处理的对象
	Duel.SetTargetCard(tc)
	-- 注册将手卡或卡组的1只怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ③得到之效果的效果处理：将1只「燃烧拳击手」怪兽送去墓地，并把对方怪兽叠放为此卡的超量素材
function c10300821.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡或卡组选择1只符合条件的「燃烧拳击手」怪兽
	local g=Duel.SelectMatchingCard(tp,c10300821.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 如果选定的怪兽成功送去墓地，则继续执行后续处理
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0
		and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取作为效果对象的对方怪兽
		local tc=Duel.GetFirstTarget()
		if c:IsRelateToChain() and tc:IsRelateToChain()
			and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 以规则原因将对方怪兽原本持有的超量素材送去墓地
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 把作为对象的对方怪兽重叠作为此卡的超量素材
			Duel.Overlay(c,tc)
		end
	end
end
