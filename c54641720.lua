--D－HERO ドレッドノートガイ
local s,id,o=GetID()
-- 注册卡片效果与融合召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材：5星以上的「D-HERO」怪兽×2
	aux.AddFusionProcFunRep(c,s.mfilter,2,true)
	-- 注册记述卡名：D-HERO 恐怖人
	aux.AddCodeList(c,40591390)
	-- 特殊召唤成功时标记
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 此卡不用融合召唤以及以下的方法不能特殊召唤。自己对「D-HERO 无畏人」1回合只能有1次特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	-- 把自己场上1只「D-HERO 恐怖人」解放的场合可以从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 此卡特殊召唤成功的场合可以发动。把「D-HERO」怪兽或者记述有「D-HERO」卡名的卡合计2张从卡组加入手牌。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- 此卡的攻击力上升自己场上·墓地的「D-HERO」怪兽的原本攻击力的合计数值。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_SET_ATTACK)
	e5:SetValue(s.val)
	c:RegisterEffect(e5)
end
s.material_setcode=0xc008
-- 融合素材过滤（等级5以上的D-HERO怪兽）
function s.mfilter(c)
	return c:IsLevelAbove(5) and c:IsFusionSetCard(0xc008)
end
-- 限制只能通过融合召唤或自身规则特招，且1回合只能特招1次
function s.splimit(e,se,sp,st)
	-- 检查是否为融合召唤且本回合未特招过同名卡
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- 检查是否为融合召唤出场或通过自身手续特招出场
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 注册玩家本回合已特招该卡的标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册回合结束前生效的特招标记
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 自身规则特招素材过滤（场上的「D-HERO 恐怖人」）
function s.hspfilter(c,tp,fc)
	return c:IsFusionCode(40591390) and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
		-- 检查解放该卡后额外卡组怪兽区是否有空位
		and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0
end
-- 自身规则特招条件判断
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查本回合是否已特招过同名卡
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	-- 检查场上是否存在可解放的「D-HERO 恐怖人」
	return Duel.CheckReleaseGroupEx(tp,s.hspfilter,1,REASON_SPSUMMON,false,nil,tp,c)
end
-- 选择自身规则特招所需解放的素材怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上符合条件的「D-HERO 恐怖人」组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.hspfilter,nil,tp,c)
	-- 提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行自身规则特招的解放操作并注册标记
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	-- 解放选择的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤可检索的D-HERO怪兽或记述D-HERO的卡
function s.thfilter(c)
	-- 判断是否为D-HERO怪兽或记述D-HERO且可加入手牌的卡
	return (c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) or aux.IsSetNameMonsterListed(c,0xc008)) and c:IsAbleToHand()
end
-- 检索效果的目标与分类设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少2张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置连锁操作信息：检索2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 检索效果的处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查卡组是否存在至少2张符合条件的卡
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) then
		return
	end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择2张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	if g:GetCount()>0 then
		-- 将选择的2张卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上及墓地的D-HERO怪兽
function s.vfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xc008)
end
-- 计算此卡上升的攻击力数值
function s.val(e,c)
	-- 获取自己场上及墓地除自身以外的所有D-HERO怪兽
	local g=Duel.GetMatchingGroup(s.vfilter,c:GetControler(),LOCATION_MZONE+LOCATION_GRAVE,0,c)
	return g:GetSum(Card.GetBaseAttack)
end
