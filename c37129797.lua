--ヴァンパイア・サッカー
-- 效果：
-- 不死族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。这个效果特殊召唤的怪兽变成不死族。
-- ②：从自己·对方的墓地有不死族怪兽特殊召唤的场合发动。自己抽1张。
-- ③：自己把怪兽上级召唤的场合，可以作为自己场上的怪兽的代替而把对方场上的不死族怪兽解放。
function c37129797.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只以上满足条件的不死族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2,2)
	-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。这个效果特殊召唤的怪兽变成不死族。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37129797,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,37129797)
	e1:SetTarget(c37129797.sptg)
	e1:SetOperation(c37129797.spop)
	c:RegisterEffect(e1)
	-- ②：从自己·对方的墓地有不死族怪兽特殊召唤的场合发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37129797,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,37129798)
	e2:SetCondition(c37129797.drcon)
	e2:SetTarget(c37129797.drtg)
	e2:SetOperation(c37129797.drop)
	c:RegisterEffect(e2)
	-- ③：自己把怪兽上级召唤的场合，可以作为自己场上的怪兽的代替而把对方场上的不死族怪兽解放。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c37129797.exrtg)
	e3:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	-- 效果将e3赋予手牌中的怪兽，使其在进行上级召唤时可以额外支付祭品
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	-- 设置效果目标为手牌中的所有怪兽
	e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 定义特殊召唤过滤器，用于判断目标怪兽是否可以被特殊召唤
function c37129797.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 设置效果目标为对方墓地的不死族怪兽
function c37129797.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c37129797.spfilter(chkc,e,tp) end
	-- 判断对方墓地是否存在满足条件的不死族怪兽
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 判断对方墓地是否存在满足条件的不死族怪兽
		and Duel.IsExistingTarget(c37129797.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为连锁对象
	local g=Duel.SelectTarget(tp,c37129797.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果，将目标怪兽特殊召唤到对方场上
function c37129797.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到对方场上
		if Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
			-- 将特殊召唤的怪兽变为不死族
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_ZOMBIE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 定义墓地特殊召唤的不死族怪兽过滤器
function c37129797.drfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- 判断是否有不死族怪兽从墓地特殊召唤成功
function c37129797.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37129797.drfilter,1,e:GetHandler())
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c37129797.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的抽卡数量
	Duel.SetTargetParam(1)
	-- 设置操作信息，表示将要抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理抽卡效果，让目标玩家抽卡
function c37129797.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义上级召唤时可作为祭品的不死族怪兽过滤器
function c37129797.exrtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
